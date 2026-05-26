import 'package:flutter_test/flutter_test.dart';
import 'package:vlc_remote/models/playlist_item.dart';

void main() {
  group('PlaylistItem', () {
    test('fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'name': 'Song Name',
        'current': 'current',
      };

      final item = PlaylistItem.fromJson(json);

      expect(item.id, '123');
      expect(item.name, 'Song Name');
      expect(item.isCurrent, true);
    });

    test('fromJson should handle non-current item', () {
      final json = {
        'id': 456,
        'name': 'Other Song',
      };

      final item = PlaylistItem.fromJson(json);

      expect(item.id, '456');
      expect(item.isCurrent, false);
    });
  });
}
