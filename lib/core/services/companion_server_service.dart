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

  /// The API token used to authenticate requests from the browser extension
  /// and MCP clients. Generated on first start and persisted in secure
  /// storage. It is never handed out over HTTP: the user copies it from the
  /// app's settings into the browser extension (pairing model).
  String? _apiToken;

  /// Pending token initialization, so concurrent callers share one load.
  Future<void>? _tokenInit;

  static const _tokenStorageKey = 'companionApiToken';

  /// The current API token, or `null` if it has not been loaded yet.
  /// Use [loadApiToken] to make sure it is initialized.
  String? get apiToken => _apiToken;

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

  /// Initializes or loads the API token from secure storage (once).
  Future<void> _initToken() {
    if (_apiToken != null) {
      return Future.value();
    }
    return _tokenInit ??= _loadOrCreateToken().whenComplete(() {
      _tokenInit = null;
    });
  }

  Future<void> _loadOrCreateToken() async {
    const storage = FlutterSecureStorage();
    try {
      final stored = await storage
          .read(key: _tokenStorageKey)
          .timeout(const Duration(seconds: 10));
      if (stored != null && stored.isNotEmpty) {
        _apiToken = stored;
        return;
      }
      final token = _generateToken();
      _apiToken = token;
      await storage.write(key: _tokenStorageKey, value: token);
    } catch (e) {
      log('Fehler beim Laden des Tokens aus SecureStorage: $e',
          name: 'CompanionServer');
      _apiToken ??= _generateToken();
    }
  }

  /// Returns the API token, loading or creating it if necessary.
  Future<String> loadApiToken() async {
    await _initToken();
    return _apiToken!;
  }

  /// Creates a new API token, persists it in secure storage and activates it
  /// immediately. Previously paired clients must be updated afterwards.
  /// Throws if the token could not be persisted; the old token stays active.
  Future<String> regenerateApiToken() async {
    await _initToken();
    final token = _generateToken();
    const storage = FlutterSecureStorage();
    await storage
        .write(key: _tokenStorageKey, value: token)
        .timeout(const Duration(seconds: 10));
    _apiToken = token;
    return token;
  }

  /// Compares two strings in constant time (relative to their length) to
  /// avoid leaking the token via timing differences.
  static bool _constantTimeEquals(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    var diff = aBytes.length ^ bBytes.length;
    for (var i = 0; i < aBytes.length; i++) {
      diff |= aBytes[i] ^ (i < bBytes.length ? bBytes[i] : 0);
    }
    return diff == 0;
  }

  /// Validates the API token from the request header.
  /// Returns true if the token is valid, false otherwise.
  bool _isAuthenticated(Request request) {
    final token = request.headers['x-api-token'];
    final expected = _apiToken;
    if (token == null || expected == null || expected.isEmpty) {
      return false;
    }
    return _constantTimeEquals(token, expected);
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

    // Health check. Deliberately unauthenticated and WITHOUT the token:
    // the token is paired manually via the app settings.
    router.get('/api/status', (Request request) {
      return _corsResponse(
        request,
        jsonEncode({
          'status': 'ok',
          'app': 'JobTracker',
        }),
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
    //
    // Note: this is a minimal implementation of the MCP "HTTP+SSE" transport.
    // Responses are NOT routed per session: every JSON-RPC response is
    // broadcast to all currently connected SSE clients (see [_sendToMcpClients]).
    // In practice only one MCP client is connected at a time; clients ignore
    // responses with ids they did not issue. Per-session routing would require
    // a session id in the endpoint URL (`/mcp/message?sessionId=...`).
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

      Object? decoded;
      try {
        decoded = await compute(jsonDecode, payload);
      } on FormatException catch (e) {
        log('Companion Server: Invalid JSON in /mcp/message: $e',
            name: 'CompanionServer');
        return Response(
          400,
          body: jsonEncode(_rpcError(null, -32700, 'Parse error')),
          headers: _corsHeaders(request),
        );
      }

      Map<String, dynamic>? response;
      try {
        response = await _handleMcpRequest(decoded);
      } catch (e) {
        log('Companion Server: MCP Error: $e', name: 'CompanionServer');
        final id = decoded is Map<String, dynamic> ? decoded['id'] : null;
        response = _rpcError(id, -32603, 'Internal error');
      }

      if (response != null) {
        _sendToMcpClients(jsonEncode(response));
      }
      return Response(202, body: 'Accepted', headers: _corsHeaders(request));
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

  /// Sends an SSE message to all connected MCP clients (broadcast, see the
  /// comment at the `/mcp/sse` route). Closed clients are skipped/removed.
  void _sendToMcpClients(String json) {
    for (final client in List.of(_mcpClients)) {
      if (client.isClosed) {
        _mcpClients.remove(client);
        continue;
      }
      try {
        client.add('event: message\ndata: $json\n\n');
      } catch (e) {
        log('Companion Server: Failed to send MCP message: $e',
            name: 'CompanionServer');
        _mcpClients.remove(client);
      }
    }
  }

  Map<String, dynamic> _rpcResult(Object? id, Map<String, dynamic> result) =>
      {'jsonrpc': '2.0', 'id': id, 'result': result};

  Map<String, dynamic> _rpcError(Object? id, int code, String message) => {
        'jsonrpc': '2.0',
        'id': id,
        'error': {'code': code, 'message': message},
      };

  Map<String, dynamic> _toolText(Object? id, String text,
          {bool isError = false}) =>
      _rpcResult(id, {
        'content': [
          {'type': 'text', 'text': text},
        ],
        if (isError) 'isError': true,
      });

  /// Handles a single JSON-RPC message. Returns the response to send, or
  /// `null` for notifications (messages without an `id`).
  Future<Map<String, dynamic>?> _handleMcpRequest(Object? decoded) async {
    if (decoded is! Map<String, dynamic>) {
      // Batches are not supported.
      return _rpcError(null, -32600, 'Invalid Request');
    }
    final req = decoded;
    final id = req['id'];
    final method = req['method'];
    final isNotification = !req.containsKey('id');

    if (method is! String) {
      return isNotification ? null : _rpcError(id, -32600, 'Invalid Request');
    }
    if (id != null && id is! String && id is! num) {
      return _rpcError(null, -32600, 'Invalid Request: id');
    }
    // Notifications (e.g. "notifications/initialized") never get a response.
    if (isNotification) {
      return null;
    }

    switch (method) {
      case 'initialize':
        return _rpcResult(id, {
          'protocolVersion': '2024-11-05',
          'capabilities': {'tools': {}},
          'serverInfo': {'name': 'CareerCenterMCP', 'version': '1.0.0'},
        });
      case 'ping':
        return _rpcResult(id, {});
      case 'tools/list':
        return _rpcResult(id, {
          'tools': [
            {
              'name': 'get_applications',
              'description': 'Liest alle Bewerbungen aus der Datenbank',
              'inputSchema': {'type': 'object', 'properties': {}},
            },
            {
              'name': 'update_cover_letter',
              'description': 'Aktualisiert das Anschreiben einer Bewerbung',
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
        });
      case 'tools/call':
        return _handleToolCall(id, req['params']);
      default:
        return _rpcError(id, -32601, 'Method not found: $method');
    }
  }

  Future<Map<String, dynamic>> _handleToolCall(
      Object? id, Object? rawParams) async {
    if (rawParams != null && rawParams is! Map<String, dynamic>) {
      return _rpcError(id, -32602, 'Invalid params');
    }
    final params = (rawParams as Map<String, dynamic>?) ?? const {};
    final toolName = params['name'];
    final rawArgs = params['arguments'];
    if (toolName is! String) {
      return _rpcError(id, -32602, 'Invalid params: name fehlt');
    }
    if (rawArgs != null && rawArgs is! Map<String, dynamic>) {
      return _rpcError(id, -32602, 'Invalid params: arguments');
    }
    final args = (rawArgs as Map<String, dynamic>?) ?? const {};

    final db = database;
    switch (toolName) {
      case 'get_applications':
        if (db == null) {
          return _rpcError(id, -32603, 'Datenbank nicht verfügbar');
        }
        final apps = await db.applicationsDao.getAllApplications();
        final mapped = apps
            .map((a) => {'id': a.id, 'company': a.company, 'position': a.position})
            .toList();
        return _toolText(id, jsonEncode(mapped));
      case 'update_cover_letter':
        final appId = args['app_id'];
        final content = args['content'];
        if (appId is! int) {
          return _rpcError(
              id, -32602, 'Invalid params: app_id muss eine Ganzzahl sein');
        }
        if (content is! String) {
          return _rpcError(
              id, -32602, 'Invalid params: content muss ein String sein');
        }
        if (db == null) {
          return _rpcError(id, -32603, 'Datenbank nicht verfügbar');
        }
        String finalContent = content;
        if (!content.trim().startsWith('[')) {
          finalContent = jsonEncode([
            {'insert': '$content\n'},
          ]);
        }

        final app = await db.applicationsDao.getApplicationById(appId);
        if (app == null) {
          return _toolText(id, 'Bewerbung nicht gefunden', isError: true);
        }
        await db.applicationsDao.updateApplication(
          app
              .toCompanion(true)
              .copyWith(coverLetterContent: drift.Value(finalContent)),
        );
        return _toolText(id, 'Erfolg');
      default:
        return _rpcError(id, -32602, 'Unknown tool: $toolName');
    }
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
