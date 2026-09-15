import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../data/database/app_database.dart';

class CompanionEvent {
  final String type;
  final Map<String, dynamic> payload;

  CompanionEvent(this.type, this.payload);
}

/// Callback to fetch a setting value by key from the app's database.
/// Set this before calling [start].
typedef SettingsFetcher = Future<String?> Function(String key);

/// Callback to store a setting value by key in the app's database.
typedef SettingsWriter = Future<void> Function(String key, String value);

class CompanionServerService {
  static final CompanionServerService _instance =
      CompanionServerService._internal();
  factory CompanionServerService() => _instance;
  CompanionServerService._internal();

  HttpServer? _server;
  Function(CompanionEvent)? onEvent;
  SettingsFetcher? settingsFetcher;
  SettingsWriter? settingsWriter;
  AppDatabase? database;
  final List<StreamController<String>> _mcpClients = [];

  final int port = 47392;

  /// The API token used to authenticate requests from the browser extension.
  /// Generated on first start and persisted in app settings.
  String? _apiToken;

  /// Allowed CORS origins for the browser extension.
  static const _allowedOriginPrefixes = [
    'chrome-extension://',
    'moz-extension://',
    'safari-web-extension://',
  ];

  /// Generates a cryptographically random API token.
  String _generateToken() {
    final random = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(48, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Initializes or loads the API token from secure storage.
  Future<void> _initToken() async {
    const storage = FlutterSecureStorage();
    try {
      _apiToken = await storage.read(key: 'companionApiToken');
      if (_apiToken == null || _apiToken!.isEmpty) {
        _apiToken = _generateToken();
        await storage.write(key: 'companionApiToken', value: _apiToken!);
      }
    } catch (e) {
      log('Fehler beim Laden des Tokens aus SecureStorage: $e');
      _apiToken = _generateToken();
    }
  }

  /// Validates the API token from the request header.
  /// Returns true if the token is valid, false otherwise.
  bool _isAuthenticated(Request request) {
    final token = request.headers['x-api-token'];
    return token != null && token == _apiToken;
  }

  /// Checks if the request origin is from an allowed browser extension.
  bool _isAllowedOrigin(String? origin) {
    if (origin == null) {
      return false; // Deny requests without Origin header to prevent trivial token leakage
    }
    return _allowedOriginPrefixes.any((prefix) => origin.startsWith(prefix));
  }

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    await _initToken();

    final router = Router();

    // Health check / Handshake — returns token for authenticated extensions
    router.get('/api/status', (Request request) {
      final origin = request.headers['origin'];
      // Only provide the token to allowed extension origins
      if (_isAllowedOrigin(origin)) {
        return _corsResponse(
          request,
          jsonEncode({
            'status': 'ok',
            'app': 'JobTracker',
            'token': _apiToken,
          }),
        );
      }
      return _corsResponse(
        request,
        jsonEncode({'status': 'ok', 'app': 'JobTracker'}),
      );
    });

    // Import Webpage
    router.post('/api/import', (Request request) async {
      if (!_isAuthenticated(request)) {
        return Response.forbidden(
          '{"error": "Unauthorized"}',
          headers: _corsHeaders(request),
        );
      }
      
      try {
        final payload = await _readWithLimit(request, 5 * 1024 * 1024);
        final decoded = await compute(jsonDecode, payload);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Expected JSON object');
        }
        final data = decoded;

        // Wake up window!
        if (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          await windowManager.show();
          await windowManager.focus();
        }

        // Broadcast event
        onEvent?.call(CompanionEvent('import', data));

        return _corsResponse(request, '{"status": "success"}');
      } on FormatException catch (e) {
        log('Companion Server: Invalid JSON in /api/import: $e',
            name: 'CompanionServer');
        return Response.badRequest(
          body: '{"error": "Invalid JSON format"}',
          headers: _corsHeaders(request),
        );
      } catch (e) {
        log('Companion Server: Error in /api/import: $e',
            name: 'CompanionServer');
        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: _corsHeaders(request),
        );
      }
    });

    // MCP SSE Endpoint
    router.get('/mcp/sse', (Request request) {
      if (!_isAuthenticated(request)) {
        return Response.forbidden(
          '{"error": "Unauthorized"}',
          headers: _corsHeaders(request),
        );
      }
      final controller = StreamController<String>();
      _mcpClients.add(controller);
      controller.onCancel = () {
        _mcpClients.remove(controller);
        controller.close();
      };
      controller.add('event: endpoint\ndata: /mcp/message\n\n');
      final stream = controller.stream.map((event) => utf8.encode(event));
      return Response.ok(
        stream,
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
        }..addAll(_corsHeaders(request)),
        context: {'shelf.io.buffer_output': false},
      );
    });

    // MCP Message Endpoint
    router.post('/mcp/message', (Request request) async {
      if (!_isAuthenticated(request)) {
        return Response.forbidden(
          '{"error": "Unauthorized"}',
          headers: _corsHeaders(request),
        );
      }
      
      String payload;
      try {
        payload = await _readWithLimit(request, 5 * 1024 * 1024);
      } catch (e) {
        return Response(413, body: '{"error": "Payload too large"}', headers: _corsHeaders(request));
      }

      if (payload.isEmpty) {
        return Response.ok('OK');
      }
      try {
        final decoded = await compute(jsonDecode, payload);
        if (decoded is! Map<String, dynamic>) {
           throw const FormatException('Expected JSON object');
        }
        final req = decoded;
        final method = req['method'];
        final id = req['id'];

        Map<String, dynamic>? response;
        if (method == 'initialize') {
          response = {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'protocolVersion': '2024-11-05',
              'capabilities': {'tools': {}},
              'serverInfo': {'name': 'CareerCenterMCP', 'version': '1.0.0'},
            },
          };
        } else if (method == 'tools/list') {
          response = {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'tools': [
                {
                  'name': 'get_applications',
                  'description': 'Liest alle Bewerbungen aus der Datenbank',
                  'inputSchema': {'type': 'object', 'properties': {}},
                },
                {
                  'name': 'update_cover_letter',
                  'description':
                      'Aktualisiert das Anschreiben einer Bewerbung',
                  'inputSchema': {
                    'type': 'object',
                    'properties': {
                      'app_id': {'type': 'integer'},
                      'content': {'type': 'string'},
                    },
                    'required': ['app_id', 'content'],
                  },
                },
              ],
            },
          };
        } else if (method == 'tools/call') {
          final params = req['params'] as Map<String, dynamic>? ?? {};
          final toolName = params['name'];
          final args = params['arguments'] as Map<String, dynamic>? ?? {};

          if (toolName == 'get_applications') {
            final apps = await database?.applicationsDao.getAllApplications();
            final mapped = apps?.map((a) => {'id': a.id, 'company': a.company, 'position': a.position}).toList();
            response = {
              'jsonrpc': '2.0',
              'id': id,
              'result': {
                'content': [
                  {'type': 'text', 'text': jsonEncode(mapped)}
                ]
              },
            };
          } else if (toolName == 'update_cover_letter' && database != null) {
            final appId = args['app_id'] as int;
            final content = args['content'] as String;
            String finalContent = content;
            if (!content.trim().startsWith('[')) {
              finalContent = jsonEncode([
                {'insert': '$content\n'},
              ]);
            }

            final app = await database!.applicationsDao.getApplicationById(
              appId,
            );
            if (app != null) {
              await database!.applicationsDao.updateApplication(
                app
                    .toCompanion(true)
                    .copyWith(coverLetterContent: drift.Value(finalContent)),
              );
            }
            response = {
              'jsonrpc': '2.0',
              'id': id,
              'result': {
                'content': [
                  {'type': 'text', 'text': app != null ? 'Erfolg' : 'Bewerbung nicht gefunden'},
                ],
              },
            };
          }
        }

        if (response != null) {
          final respStr = jsonEncode(response);
          for (final client in _mcpClients) {
            client.add('event: message\ndata: $respStr\n\n');
          }
        }
      } on FormatException catch (e) {
        log('Companion Server: Invalid JSON in /mcp/message: $e',
            name: 'CompanionServer');
      } catch (e) {
        log('Companion Server: MCP Error: $e',
            name: 'CompanionServer');
      }
      return _corsResponse(request, 'Accepted');
    });

    // GET /api/profile — returns user profile as JSON for browser extension autofill
    router.get('/api/profile', (Request request) async {
      if (!_isAuthenticated(request)) {
        return Response.forbidden(
          '{"error": "Unauthorized"}',
          headers: _corsHeaders(request),
        );
      }
      try {
        final fetch = settingsFetcher;
        if (fetch == null) {
          return _corsResponse(request, '{"error": "Profile not available"}');
        }

        final name = await fetch('userName') ?? '';
        final email = await fetch('userEmail') ?? '';
        final phone = await fetch('userPhone') ?? '';
        final address = await fetch('userAddress') ?? '';
        final city = await fetch('userCity') ?? '';
        final zip = await fetch('userZip') ?? '';
        final birthdate = await fetch('userBirthdate') ?? '';
        final skills = await fetch('userSkills') ?? '';
        final linkedin = await fetch('userLinkedin') ?? '';
        final website = await fetch('userWebsite') ?? '';

        // Split name into first/last for portals that use separate fields
        final nameParts = name.trim().split(RegExp(r'\s+'));
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        final profile = {
          'fullName': name,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'city': city,
          'zip': zip,
          'birthdate': birthdate,
          'skills': skills,
          'linkedin': linkedin,
          'website': website,
        };

        return _corsResponse(request, jsonEncode(profile));
      } catch (e) {
        log('Companion Server: Error in /api/profile: $e',
            name: 'CompanionServer');
        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: _corsHeaders(request),
        );
      }
    });

    // POST /api/autofill — legacy: bring window to front (kept for compatibility)
    router.post('/api/autofill', (Request request) async {
      if (!_isAuthenticated(request)) {
        return Response.forbidden(
          '{"error": "Unauthorized"}',
          headers: _corsHeaders(request),
        );
      }
      // Wakes up in overlay mode
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // Bring to front and maybe resize/always on top
        await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
      }

      onEvent?.call(CompanionEvent('autofill_request', {}));
      return _corsResponse(request, '{"status": "ready"}');
    });

    final handler = const Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await io.serve(handler, '127.0.0.1', port);
    debugPrint('Companion Server listening on localhost:$port');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<String> _readWithLimit(Request request, int limitBytes) async {
    final builder = BytesBuilder();
    await for (final chunk in request.read()) {
      builder.add(chunk);
      if (builder.length > limitBytes) {
        throw Exception('Payload exceeded limit');
      }
    }
    return utf8.decode(builder.toBytes());
  }

  Map<String, String> _corsHeaders(Request request) {
    final origin = request.headers['origin'];
    // Only reflect the origin if it's from an allowed browser extension
    final allowedOrigin =
        (origin != null && _isAllowedOrigin(origin)) ? origin : '';
    return {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers':
          'Origin, Content-Type, Accept, X-API-Token',
      'Content-Type': 'application/json',
      'Vary': 'Origin',
    };
  }

  Response _corsResponse(Request request, String body) {
    return Response.ok(body, headers: _corsHeaders(request));
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders(request));
        }
        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders(request));
      };
    };
  }
}
