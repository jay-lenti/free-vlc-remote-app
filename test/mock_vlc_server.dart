import 'dart:convert';
import 'dart:io';

class MockVlcServer {
  late HttpServer _server;
  int port = 0;
  String password = 'password';

  String state = 'stopped';
  int volume = 128;
  int time = 0;
  int length = 300;
  String title = 'Mock Song';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    port = _server.port;
    
    _server.listen((HttpRequest request) {
      // Check Auth
      String? authHeader = request.headers.value('Authorization');
      String expectedAuth = 'Basic ${base64Encode(utf8.encode(':$password'))}';
      
      if (authHeader != expectedAuth) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.add('WWW-Authenticate', 'Basic realm="VLC HTTP"');
        request.response.close();
        return;
      }

      final uri = request.uri;
      if (uri.path == '/requests/status.json') {
        _handleStatus(request);
      } else if (uri.path == '/requests/playlist.json') {
        _handlePlaylist(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    });
  }

  void _handleStatus(HttpRequest request) {
    final command = request.uri.queryParameters['command'];
    final val = request.uri.queryParameters['val'];

    if (command == 'pl_pause') {
      state = (state == 'playing') ? 'paused' : 'playing';
    } else if (command == 'pl_stop') {
      state = 'stopped';
      time = 0;
    } else if (command == 'volume') {
      volume = int.tryParse(val ?? '0') ?? volume;
    } else if (command == 'seek') {
      time = int.tryParse(val ?? '0') ?? time;
    }

    final response = {
      'state': state,
      'volume': volume,
      'time': time,
      'length': length,
      'information': {
        'category': {
          'meta': {
            'title': title,
            'artist': 'Mock Artist',
          }
        }
      }
    };

    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(response))
      ..close();
  }

  void _handlePlaylist(HttpRequest request) {
    final response = {
      'children': [
        {
          'type': 'node',
          'name': 'Playlist',
          'children': [
            {'type': 'leaf', 'id': '1', 'name': 'Mock Song 1', 'current': state == 'playing' ? 'current' : ''},
            {'type': 'leaf', 'id': '2', 'name': 'Mock Song 2', 'current': ''},
          ]
        }
      ]
    };

    request.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(response))
      ..close();
  }

  Future<void> stop() async {
    await _server.close();
  }
}
