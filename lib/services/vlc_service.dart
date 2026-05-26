import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vlc_status.dart';
import '../models/playlist_item.dart';

class VlcService {
  String ip;
  int port;
  String password;

  VlcService({
    required this.ip,
    required this.port,
    required this.password,
  });

  String get _baseUrl => 'http://$ip:$port/requests';

  Map<String, String> get _headers {
    String auth = base64Encode(utf8.encode(':$password'));
    return {
      'Authorization': 'Basic $auth',
    };
  }

  Future<VlcStatus> getStatus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/status.json'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return VlcStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load VLC status');
    }
  }

  Future<List<PlaylistItem>> getPlaylist() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/playlist.json'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // VLC playlist is a tree structure, but usually it's simple
      // We'll flatten it for simplicity if needed, or just look for the main node
      List<dynamic> children = data['children'] ?? [];
      List<PlaylistItem> items = [];
      
      void extractItems(List<dynamic> nodes) {
        for (var node in nodes) {
          if (node['type'] == 'leaf') {
            items.add(PlaylistItem.fromJson(node));
          } else if (node['children'] != null) {
            extractItems(node['children']);
          }
        }
      }

      extractItems(children);
      return items;
    } else {
      throw Exception('Failed to load VLC playlist');
    }
  }

  Future<void> sendCommand(String command, {String? val}) async {
    String url = '$_baseUrl/status.json?command=$command';
    if (val != null) {
      url += '&val=$val';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send command: $command');
    }
  }
}
