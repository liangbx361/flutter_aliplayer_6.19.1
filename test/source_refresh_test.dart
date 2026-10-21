import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_test/flutter_test.dart';

// These tests simulate native channel requests, not SDK expiry detection.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  const codec = StandardMethodCodec();
  const refreshChannel = 'plugins.flutter_aliplayer_source_refresh';
  const eventChannel = MethodChannel('flutter_aliplayer_event');
  final nativeCalls = <MethodCall>[];

  Future<Map<String, dynamic>> requestRefresh(
      String method, String playerId, String value) {
    final response = Completer<Map<String, dynamic>>();
    binding.channelBuffers.push(
      refreshChannel,
      codec.encodeMethodCall(MethodCall(method, {
        'playerId': playerId,
        'value': value,
      })),
      (data) {
        try {
          response.complete(
              Map<String, dynamic>.from(codec.decodeEnvelope(data!) as Map));
        } catch (error, stackTrace) {
          response.completeError(error, stackTrace);
        }
      },
    );
    return response.future;
  }

  setUp(() {
    nativeCalls.clear();
    FlutterAliPlayerFactory.instanceMap.clear();
    messenger.setMockMethodCallHandler(FlutterAliPlayerFactory.methodChannel,
        (call) async {
      nativeCalls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(eventChannel, (_) async => null);
  });

  tearDown(() {
    FlutterAliPlayerFactory.instanceMap.clear();
    const MethodChannel(refreshChannel).setMethodCallHandler(null);
    messenger.setMessageHandler(eventChannel.name, null);
    messenger.setMockMethodCallHandler(
        FlutterAliPlayerFactory.methodChannel, null);
    messenger.setMockMethodCallHandler(eventChannel, null);
  });

  test('registration enables and disables each native listener for the player',
      () async {
    final player = FlutterAliplayer.init('player');
    await player.setOnVidAuthExpiredCallback((_, callback, __) {});
    await player.setOnURLSourceExpiredCallback((_, callback, __) {});
    await player.setOnVidAuthExpiredCallback(null);
    await player.setOnURLSourceExpiredCallback(null);

    expect(nativeCalls.map((call) => call.method), [
      'setOnVidAuthExpiredCallback',
      'setOnURLSourceExpiredCallback',
      'setOnVidAuthExpiredCallback',
      'setOnURLSourceExpiredCallback',
    ]);
    expect(nativeCalls.map((call) => call.arguments), [
      {'playerId': 'player', 'arg': true},
      {'playerId': 'player', 'arg': true},
      {'playerId': 'player', 'arg': false},
      {'playerId': 'player', 'arg': false},
    ]);
  });

  test(
      'URL request waits for business completion and returns the refreshed URL',
      () async {
    final player = FlutterAliplayer.init('url-player');
    final started = Completer<void>();
    final refreshed = Completer<String>();
    await player.setOnURLSourceExpiredCallback((url, callback, playerId) async {
      expect(url, 'https://video.example/old.m3u8?auth=old');
      expect(playerId, 'url-player');
      started.complete();
      callback.onSuccess(await refreshed.future);
    });

    var hasResponded = false;
    final result = requestRefresh('onURLSourceExpired', 'url-player',
        'https://video.example/old.m3u8?auth=old');
    unawaited(result.then((_) => hasResponded = true));
    await started.future;
    expect(hasResponded, isFalse);

    refreshed.complete('https://video.example/new.m3u8?auth=new');
    expect(await result, {'value': 'https://video.example/new.m3u8?auth=new'});
  });

  test('VidAuth request passes the vid and returns only the new PlayAuth',
      () async {
    final player = FlutterAliplayer.init('auth-player');
    await player.setOnVidAuthExpiredCallback((vid, callback, playerId) async {
      expect(vid, 'video-id');
      expect(playerId, 'auth-player');
      callback.onSuccess('new-play-auth');
    });

    expect(await requestRefresh('onVidAuthExpired', 'auth-player', 'video-id'),
        {'value': 'new-play-auth'});
  });

  test('multiple registered players dispatch each request exactly once',
      () async {
    final calls = <String>[];
    for (final id in ['first', 'second', 'third']) {
      final player = FlutterAliplayer.init(id);
      await player.setOnVidAuthExpiredCallback((value, callback, playerId) {
        calls.add('$id:auth:$playerId:$value');
        callback.onSuccess('$id-auth');
      });
      await player.setOnURLSourceExpiredCallback((value, callback, playerId) {
        calls.add('$id:url:$playerId:$value');
        callback.onSuccess('$id-url');
      });
    }

    expect(await requestRefresh('onURLSourceExpired', 'first', 'old-url'),
        {'value': 'first-url'});
    expect(await requestRefresh('onVidAuthExpired', 'second', 'old-vid'),
        {'value': 'second-auth'});
    expect(calls, [
      'first:url:first:old-url',
      'second:auth:second:old-vid',
    ]);
  });

  test('explicit errors and async business exceptions return SDK failures',
      () async {
    final player = FlutterAliplayer.init('player');
    await player.setOnURLSourceExpiredCallback((_, callback, __) {
      callback.onError('The business refresh failed');
    });
    await player.setOnVidAuthExpiredCallback((_, callback, __) async {
      await Future<void>.value();
      throw StateError('The authorization service failed');
    });

    expect(await requestRefresh('onURLSourceExpired', 'player', 'old-url'),
        {'errorMsg': 'The business refresh failed'});
    expect(await requestRefresh('onVidAuthExpired', 'player', 'vid'),
        {'errorMsg': contains('The authorization service failed')});
  });

  test('empty refreshed sources and empty errors become failures', () async {
    final player = FlutterAliplayer.init('player');
    for (final value in ['', ' \t\n']) {
      await player.setOnURLSourceExpiredCallback((_, callback, __) {
        callback.onSuccess(value);
      });
      expect(await requestRefresh('onURLSourceExpired', 'player', 'old-url'),
          {'errorMsg': 'The refreshed source must not be empty'});
    }
    await player.setOnVidAuthExpiredCallback((_, callback, __) {
      callback.onError('');
    });
    expect(await requestRefresh('onVidAuthExpired', 'player', 'vid'),
        {'errorMsg': 'Source refresh failed'});
  });

  test('only the first business completion is delivered', () async {
    final player = FlutterAliplayer.init('player');
    await player.setOnURLSourceExpiredCallback((_, callback, __) {
      expect(callback.isCompleted, isFalse);
      callback.onSuccess('first-url');
      expect(callback.isCompleted, isTrue);
      callback.onError('late failure');
      callback.onSuccess('late-url');
    });
    expect(await requestRefresh('onURLSourceExpired', 'player', 'old-url'),
        {'value': 'first-url'});

    await player.setOnVidAuthExpiredCallback((_, callback, __) {
      callback.onError('first failure');
      callback.onSuccess('late-auth');
    });
    expect(await requestRefresh('onVidAuthExpired', 'player', 'vid'),
        {'errorMsg': 'first failure'});
  });

  test('source changes, stop, and release cancel pending refreshes', () async {
    final actions = <String, Future<void> Function(FlutterAliplayer)>{
      'setUrl': (player) => player.setUrl('replacement-url'),
      'setVidAuth': (player) => player.setVidAuth(vid: 'replacement-vid'),
      'setVidSts': (player) => player.setVidSts(vid: 'replacement-vid'),
      'setVidMps': (player) => player.setVidMps({'vid': 'replacement-vid'}),
      'setLiveSts': (player) => player.setLiveSts(url: 'replacement-url'),
      'stop': (player) => player.stop(),
      'destroy': (player) => player.destroy(),
      'releaseAsync': (player) => player.releaseAsync(),
    };
    for (final action in actions.entries) {
      final id = action.key;
      final player = FlutterAliplayer.init(id);
      final started = Completer<SourceRefreshCallback>();
      await player.setOnURLSourceExpiredCallback((_, callback, __) {
        started.complete(callback);
      });
      final result = requestRefresh('onURLSourceExpired', id, 'old-url');
      final callback = await started.future;

      await action.value(player);
      final response = await result;
      expect(response.keys, ['errorMsg'], reason: id);
      expect(callback.isCompleted, isTrue, reason: id);
      callback.onSuccess('late-url');
      expect(await result, response, reason: id);
    }
  });

  test('removing a listener cancels only its own pending request type',
      () async {
    final player = FlutterAliplayer.init('player');
    final urlStarted = Completer<SourceRefreshCallback>();
    final authStarted = Completer<SourceRefreshCallback>();
    await player.setOnURLSourceExpiredCallback((_, callback, __) {
      urlStarted.complete(callback);
    });
    await player.setOnVidAuthExpiredCallback((_, callback, __) {
      authStarted.complete(callback);
    });
    final urlResult = requestRefresh('onURLSourceExpired', 'player', 'old-url');
    final authResult = requestRefresh('onVidAuthExpired', 'player', 'vid');
    final urlCallback = await urlStarted.future;
    final authCallback = await authStarted.future;

    await player.setOnURLSourceExpiredCallback(null);
    expect(await urlResult, {'errorMsg': 'The refresh listener changed'});
    expect(authCallback.isCompleted, isFalse);
    authCallback.onSuccess('new-auth');
    urlCallback.onSuccess('late-url');
    expect(await authResult, {'value': 'new-auth'});
  });

  test('released player requests never fall back to another player', () async {
    final released = FlutterAliplayer.init('released');
    final survivor = FlutterAliplayer.init('survivor');
    var survivorCalls = 0;
    await survivor.setOnURLSourceExpiredCallback((_, callback, __) {
      survivorCalls++;
      callback.onSuccess('wrong-player-url');
    });
    await released.releaseAsync();

    expect(await requestRefresh('onURLSourceExpired', 'released', 'old-url'),
        {'errorMsg': 'The player has been released'});
    expect(survivorCalls, 0);
  });

  test('replacing a player cancels old requests and routes to the new listener',
      () async {
    final oldPlayer = FlutterAliplayer.init('player');
    final oldStarted = Completer<SourceRefreshCallback>();
    var oldCalls = 0;
    await oldPlayer.setOnURLSourceExpiredCallback((_, callback, __) {
      oldCalls++;
      oldStarted.complete(callback);
    });
    final oldResult = requestRefresh('onURLSourceExpired', 'player', 'old-url');
    final oldCallback = await oldStarted.future;

    final newPlayer = FlutterAliplayer.init('player');
    final replacementResult = {'errorMsg': 'The player was replaced'};
    expect(await oldResult, replacementResult);
    expect(oldCallback.isCompleted, isTrue);
    oldCallback.onSuccess('late-old-url');
    expect(await oldResult, replacementResult);

    var newCalls = 0;
    await newPlayer.setOnURLSourceExpiredCallback((url, callback, playerId) {
      expect(url, 'new-old-url');
      expect(playerId, 'player');
      newCalls++;
      callback.onSuccess('new-player-url');
    });

    expect(await requestRefresh('onURLSourceExpired', 'player', 'new-old-url'),
        {'value': 'new-player-url'});
    expect(oldCalls, 1);
    expect(newCalls, 1);
  });

  test('unregistered expiry callbacks return an explicit failure', () async {
    FlutterAliplayer.init('player');
    for (final method in ['onVidAuthExpired', 'onURLSourceExpired']) {
      expect(await requestRefresh(method, 'player', 'old-source'),
          {'errorMsg': 'No source refresh callback is registered'});
    }
  });

  test('SDK errors still reach onError without inferring authorization expiry',
      () async {
    final player = FlutterAliplayer.init('player');
    var refreshCalls = 0;
    await player.setOnURLSourceExpiredCallback((_, callback, __) {
      refreshCalls++;
      callback.onSuccess('new-url');
    });
    final received = Completer<List<Object?>>();
    player.setOnError((code, extra, message, playerId) {
      received.complete([code, extra, message, playerId]);
    });

    binding.channelBuffers.push(
      eventChannel.name,
      codec.encodeSuccessEnvelope({
        'method': 'onError',
        'playerId': 'player',
        'errorCode': 403,
        'errorExtra': 'segment.ts',
        'errorMsg': 'Segment request failed',
      }),
      (_) {},
    );

    expect(await received.future,
        [403, 'segment.ts', 'Segment request failed', 'player']);
    expect(refreshCalls, 0);
  });
}
