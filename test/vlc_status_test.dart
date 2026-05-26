import 'package:flutter_test/flutter_test.dart';
import 'package:vlc_remote/models/vlc_status.dart';

void main() {
  group('VlcStatus', () {
    test('fromJson should parse correctly', () {
      final json = {
        'state': 'playing',
        'volume': 128,
        'time': 100,
        'length': 300,
        'information': {
          'category': {
            'meta': {
              'title': 'Test Title',
              'artist': 'Test Artist',
            }
          }
        }
      };

      final status = VlcStatus.fromJson(json);

      expect(status.state, 'playing');
      expect(status.volume, 128);
      expect(status.time, 100);
      expect(status.length, 300);
      expect(status.title, 'Test Title');
      expect(status.artist, 'Test Artist');
      expect(status.isPlaying, true);
    });

    test('fromJson should handle missing meta', () {
      final json = {
        'state': 'stopped',
        'volume': 0,
        'time': 0,
        'length': 0,
      };

      final status = VlcStatus.fromJson(json);

      expect(status.title, 'Unknown Title');
      expect(status.artist, 'Unknown Artist');
      expect(status.isPlaying, false);
    });
  });
}
