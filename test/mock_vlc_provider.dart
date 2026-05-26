import 'package:mocktail/mocktail.dart';
import 'package:vlc_remote/providers/vlc_provider.dart';

class MockVlcProvider extends Mock implements VlcProvider {
  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  void dispose() {}
}
