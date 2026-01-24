import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliliveshiftplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_mock.dart';

class FlutterAliListPlayerMock extends FlutterAliplayerMock
    implements FlutterAliListPlayer {
  FlutterAliListPlayerMock.init(String id) : super.init(id);

  @override
  // ignore: overridden_fields
  String playerId = 'listPlayerDefault';

  @override
  Future<void> setPreloadCount(int count) async {}
  @override
  Future<void> addVidSource({vid, uid}) async {}
  @override
  Future<void> addUrlSource({url, uid}) async {}
  @override
  Future<void> removeSource(String uid) async {}
  @override
  Future<dynamic> getCurrentUid() async => "";
  @override
  Future<void> clear() async {}
  @override
  Future<void> setMaxPreloadMemorySizeMB(int size) async {}
  @override
  Future<void> setDefinition(String definition) async {}
  @override
  Future<void> moveToNext(
      {String? accId, String? accKey, String? token, String? region}) async {}
  @override
  Future<void> moveToPre(
      {String? accId, String? accKey, String? token, String? region}) async {}
  @override
  Future<void> moveTo(
      {String? uid,
      String? accId,
      String? accKey,
      String? token,
      String? region}) async {}
}

class FlutterAliLiveShiftPlayerMock extends FlutterAliplayerMock
    implements FlutterAliLiveShiftPlayer {
  FlutterAliLiveShiftPlayerMock.init(String? id) : super.init(id);

  @override
  // ignore: overridden_fields
  String playerId = 'liveShiftPlayerDefault';

  @override
  Future<dynamic> getCurrentLiveTime() async => 0;
  @override
  Future<dynamic> getCurrentTime() async => 0;
  @override
  Future<void> seekToLiveTime(int liveTime) async {}
  @override
  Future<void> setDataSource(String timeLineUrl, String url,
      {String? coverPath, String? format, String? title}) async {}
}
