import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:vlc_remote/providers/vlc_provider.dart';
import 'package:vlc_remote/screens/home_screen.dart';
import 'package:vlc_remote/screens/settings_screen.dart';
import 'package:vlc_remote/screens/playlist_screen.dart';
import 'package:vlc_remote/models/vlc_status.dart';
import 'package:vlc_remote/models/playlist_item.dart';
import 'mock_vlc_provider.dart';

void main() {
  late MockVlcProvider mockVlcProvider;

  setUp(() {
    mockVlcProvider = MockVlcProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<VlcProvider>.value(
        value: mockVlcProvider,
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen shows disconnected message when not connected', (WidgetTester tester) async {
    when(() => mockVlcProvider.isConnected).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Not Connected to VLC'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('HomeScreen shows song info when connected', (WidgetTester tester) async {
    final mockStatus = VlcStatus(
      state: 'playing',
      volume: 128,
      time: 60,
      length: 300,
      title: 'Mock Song',
      artist: 'Mock Artist',
    );

    when(() => mockVlcProvider.isConnected).thenReturn(true);
    when(() => mockVlcProvider.status).thenReturn(mockStatus);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Mock Song'), findsOneWidget);
    expect(find.text('Mock Artist'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2)); // Seek bar and Volume slider
    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
  });

  testWidgets('SettingsScreen interaction triggers updateSettings', (WidgetTester tester) async {
    when(() => mockVlcProvider.ip).thenReturn(null);
    when(() => mockVlcProvider.port).thenReturn(8080);
    when(() => mockVlcProvider.password).thenReturn(null);
    when(() => mockVlcProvider.updateSettings(any(), any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<VlcProvider>.value(
        value: mockVlcProvider,
        child: const SettingsScreen(),
      ),
    ));

    await tester.enterText(find.widgetWithText(TextFormField, 'IP Address'), '192.168.1.100');
    await tester.enterText(find.widgetWithText(TextFormField, 'Port'), '8081');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'secret');

    await tester.tap(find.text('Save & Connect'));
    await tester.pumpAndSettle();

    verify(() => mockVlcProvider.updateSettings('192.168.1.100', 8081, 'secret')).called(1);
  });

  testWidgets('Tapping play/pause calls togglePause on provider', (WidgetTester tester) async {
    final mockStatus = VlcStatus(
      state: 'playing',
      volume: 128,
      time: 60,
      length: 300,
      title: 'Mock Song',
      artist: 'Mock Artist',
    );

    when(() => mockVlcProvider.isConnected).thenReturn(true);
    when(() => mockVlcProvider.status).thenReturn(mockStatus);
    when(() => mockVlcProvider.togglePause()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.pause_circle_filled));
    await tester.pump();

    verify(() => mockVlcProvider.togglePause()).called(1);
  });

  testWidgets('PlaylistScreen shows items and calls playItem when tapped', (WidgetTester tester) async {
    final mockPlaylist = [
      PlaylistItem(id: '1', name: 'Song 1', isCurrent: false),
      PlaylistItem(id: '2', name: 'Song 2', isCurrent: true),
    ];

    when(() => mockVlcProvider.playlist).thenReturn(mockPlaylist);
    when(() => mockVlcProvider.refreshPlaylist()).thenAnswer((_) async {});
    when(() => mockVlcProvider.playItem(any())).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider<VlcProvider>.value(
        value: mockVlcProvider,
        child: const PlaylistScreen(),
      ),
    ));

    await tester.pump(); // Handle the microtask refreshPlaylist

    expect(find.text('Song 1'), findsOneWidget);
    expect(find.text('Song 2'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.text('Song 1'));
    verify(() => mockVlcProvider.playItem('1')).called(1);
  });
}
