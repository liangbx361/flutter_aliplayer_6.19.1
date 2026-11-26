import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mock supports the source refresh API without native channels',
      () async {
    final player =
        FlutterAliPlayerFactory.createAliPlayer(playerId: 'mock-refresh');
    addTearDown(player.destroy);

    void onURLExpired(
        String url, SourceRefreshCallback callback, String playerId) {
      if (!callback.isCompleted) callback.onSuccess('$url?refreshed');
    }

    Future<void> onVidAuthExpired(
        String vid, SourceRefreshCallback callback, String playerId) async {
      await Future<void>.value();
      if (!callback.isCompleted) callback.onError('Refresh unavailable');
    }

    // Both synchronous and asynchronous business callbacks must be accepted.
    await player.setOnURLSourceExpiredCallback(onURLExpired);
    await player.setOnVidAuthExpiredCallback(onVidAuthExpired);
    expect(player.onURLSourceExpired, same(onURLExpired));
    expect(player.onVidAuthExpired, same(onVidAuthExpired));

    await player.setOnURLSourceExpiredCallback(null);
    await player.setOnVidAuthExpiredCallback(null);
    expect(player.onURLSourceExpired, isNull);
    expect(player.onVidAuthExpired, isNull);

    // Registration must not interrupt the existing pure Dart playback flow.
    var prepared = false;
    player.setOnPrepared((_) => prepared = true);
    await player.setUrl('https://example.test/video.m3u8');
    await player.prepare();
    expect(prepared, isTrue);
  });
}
