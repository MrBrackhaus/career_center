import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';

class CompanionEvent {
  final String type;
  final Map<String, dynamic> payload;
  
  CompanionEvent(this.type, this.payload);
}

/// Callback to fetch a setting value by key from the app's database.
/// Set this before calling [start].
typedef SettingsFetcher = Future<String?> Function(String key);

class CompanionServerService {
  static final CompanionServerService _instance = CompanionServerService._internal();
  factory CompanionServerService() => _instance;
  CompanionServerService._internal();

  HttpServer? _server;
  Function(CompanionEvent)? onEvent;
  SettingsFetcher? settingsFetcher;
  
  final int port = 47392;

  Future<void> start() async {
    if (_server != null) return;
    
    final router = Router();
    
    // Health check / Handshake
    router.get('/api/status', (Request request) {
      return _corsResponse('{"status": "ok", "app": "JobTracker"}');
    });
    
    // Import Webpage
    router.post('/api/import', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload) as Map<String, dynamic>;
        
        // Wake up window!
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          await windowManager.show();
          await windowManager.focus();
        }
        
        // Broadcast event
        onEvent?.call(CompanionEvent('import', data));
        
        return _corsResponse('{"status": "success"}');
      } catch (e) {
        return Response.internalServerError(
          body: '{"error": "${e.toString()}"}',
          headers: _corsHeaders(),
        );
      }
    });

    // GET /api/profile — returns user profile as JSON for browser extension autofill
    router.get('/api/profile', (Request request) async {
      try {
        final fetch = settingsFetcher;
        if (fetch == null) {
          return _corsResponse('{"error": "Profile not available"}');
        }

        final name       = await fetch('userName')       ?? '';
        final email      = await fetch('userEmail')      ?? '';
        final phone      = await fetch('userPhone')      ?? '';
        final address    = await fetch('userAddress')    ?? '';
        final city       = await fetch('userCity')       ?? '';
        final zip        = await fetch('userZip')        ?? '';
        final birthdate  = await fetch('userBirthdate')  ?? '';
        final skills     = await fetch('userSkills')     ?? '';
        final linkedin   = await fetch('userLinkedin')   ?? '';
        final website    = await fetch('userWebsite')    ?? '';

        // Split name into first/last for portals that use separate fields
        final nameParts  = name.trim().split(RegExp(r'\s+'));
        final firstName  = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName   = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final profile = {
          'fullName':  name,
          'firstName': firstName,
          'lastName':  lastName,
          'email':     email,
          'phone':     phone,
          'address':   address,
          'city':      city,
          'zip':       zip,
          'birthdate': birthdate,
          'skills':    skills,
          'linkedin':  linkedin,
          'website':   website,
        };

        return _corsResponse(jsonEncode(profile));
      } catch (e) {
        return Response.internalServerError(
          body: '{"error": "${e.toString()}"}',
          headers: _corsHeaders(),
        );
      }
    });

    // POST /api/autofill — legacy: bring window to front (kept for compatibility)
    router.post('/api/autofill', (Request request) async {
      // Wakes up in overlay mode
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // Bring to front and maybe resize/always on top
        await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
      }
      
      onEvent?.call(CompanionEvent('autofill_request', {}));
      return _corsResponse('{"status": "ready"}');
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
  
  Map<String, String> _corsHeaders() {
    return {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
      'Content-Type': 'application/json',
    };
  }
  
  Response _corsResponse(String body) {
    return Response.ok(body, headers: _corsHeaders());
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders());
        }
        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders());
      };
    };
  }
}
