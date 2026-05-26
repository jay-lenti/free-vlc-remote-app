import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vlc_status.dart';
import '../models/playlist_item.dart';
import '../services/vlc_service.dart';

class VlcProvider with ChangeNotifier {
  VlcService? _service;
  VlcStatus? _status;
  List<PlaylistItem> _playlist = [];
  bool _isConnected = false;
  Timer? _pollingTimer;

  String? _ip;
  int? _port;
  String? _password;

  VlcStatus? get status => _status;
  List<PlaylistItem> get playlist => _playlist;
  bool get isConnected => _isConnected;
  String? get ip => _ip;
  int? get port => _port;
  String? get password => _password;

  VlcProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('vlc_ip');
    _port = prefs.getInt('vlc_port') ?? 8080;
    _password = prefs.getString('vlc_password');

    if (_ip != null && _password != null) {
      _initializeService();
      startPolling();
    }
    notifyListeners();
  }

  Future<void> updateSettings(String ip, int port, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vlc_ip', ip);
    await prefs.setInt('vlc_port', port);
    await prefs.setString('vlc_password', password);

    _ip = ip;
    _port = port;
    _password = password;

    _initializeService();
    await refreshStatus();
    startPolling();
    notifyListeners();
  }

  void _initializeService() {
    if (_ip != null && _port != null && _password != null) {
      _service = VlcService(ip: _ip!, port: _port!, password: _password!);
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      refreshStatus();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> refreshStatus() async {
    if (_service == null) return;

    try {
      _status = await _service!.getStatus();
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
    }
    notifyListeners();
  }

  Future<void> refreshPlaylist() async {
    if (_service == null) return;

    try {
      _playlist = await _service!.getPlaylist();
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }

  Future<void> togglePause() async {
    await _service?.sendCommand('pl_pause');
    await refreshStatus();
  }

  Future<void> stop() async {
    await _service?.sendCommand('pl_stop');
    await refreshStatus();
  }

  Future<void> next() async {
    await _service?.sendCommand('pl_next');
    await refreshStatus();
  }

  Future<void> previous() async {
    await _service?.sendCommand('pl_previous');
    await refreshStatus();
  }

  Future<void> setVolume(int volume) async {
    // VLC volume is 0-512, where 256 is 100%
    await _service?.sendCommand('volume', val: volume.toString());
    await refreshStatus();
  }

  Future<void> seek(int seconds) async {
    await _service?.sendCommand('seek', val: seconds.toString());
    await refreshStatus();
  }

  Future<void> playItem(String id) async {
    await _service?.sendCommand('pl_play', val: id);
    await refreshStatus();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
