import 'package:flutter_test/flutter_test.dart';
import 'package:vlc_remote/services/vlc_service.dart';
import 'package:vlc_remote/providers/vlc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_vlc_server.dart';

void main() {
  late MockVlcServer mockServer;
  late VlcService vlcService;
  late VlcProvider vlcProvider;

  setUpAll(() async {
    mockServer = MockVlcServer();
    await mockServer.start();
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    await mockServer.stop();
  });

  setUp(() {
    vlcService = VlcService(
      ip: '127.0.0.1',
      port: mockServer.port,
      password: mockServer.password,
    );
    vlcProvider = VlcProvider();
  });

  group('End-to-End Service & Provider Tests', () {
    test('Service should fetch status from mock server', () async {
      final status = await vlcService.getStatus();
      expect(status.title, 'Mock Song');
      expect(status.state, 'stopped');
    });

    test('Service should fetch playlist from mock server', () async {
      final playlist = await vlcService.getPlaylist();
      expect(playlist.length, 2);
      expect(playlist[0].name, 'Mock Song 1');
    });

    test('Provider should update settings and connect', () async {
      await vlcProvider.updateSettings('127.0.0.1', mockServer.port, mockServer.password);
      expect(vlcProvider.isConnected, true);
      expect(vlcProvider.status?.title, 'Mock Song');
    });

    test('Provider should toggle pause and reflect state', () async {
      await vlcProvider.updateSettings('127.0.0.1', mockServer.port, mockServer.password);
      
      expect(vlcProvider.status?.isPlaying, false);
      await vlcProvider.togglePause();
      expect(vlcProvider.status?.isPlaying, true);
      
      await vlcProvider.togglePause();
      expect(vlcProvider.status?.isPlaying, false);
    });

    test('Provider should change volume', () async {
      await vlcProvider.updateSettings('127.0.0.1', mockServer.port, mockServer.password);
      
      await vlcProvider.setVolume(200);
      expect(vlcProvider.status?.volume, 200);
    });

    test('Provider should handle incorrect password', () async {
      final wrongProvider = VlcProvider();
      await wrongProvider.updateSettings('127.0.0.1', mockServer.port, 'wrong_pass');
      
      expect(wrongProvider.isConnected, false);
    });
  });
}
