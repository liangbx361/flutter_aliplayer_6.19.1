import 'package:flutter/material.dart';

import 'flutter_aliplayer.dart';
export 'flutter_aliplayer.dart';

class FlutterAliListPlayer extends FlutterAliplayer {
  @override
  // ignore: overridden_fields
  String playerId = 'listPlayerDefault';

  FlutterAliListPlayer.init(String id) : super.init(id);

  @override

  /// 创建短视频列表播放
  Future<void> create() async {
    mState = FlutterAvpdef.initalized;
    fireEvent("onStateChanged", {"newState": mState});
  }

  /// 设置预加载的个数
  Future<void> setPreloadCount(int count) async {
    // No-op
  }

  /// 添加vid资源到播放列表中
  Future<void> addVidSource({@required vid, @required uid}) async {
    // No-op
  }

  /// 添加url资源到播放列表中
  Future<void> addUrlSource({@required url, @required uid}) async {
    // No-op
  }

  /// 从播放列表中删除指定资源
  Future<void> removeSource(String uid) async {
    // No-op
  }

  /// 获取当前播放资源的uid
  Future<dynamic> getCurrentUid() async {
    return "";
  }

  /// 清除播放列表
  Future<void> clear() async {
    // No-op
  }

  /// 设置最大的预缓存的内存大小
  Future<void> setMaxPreloadMemorySizeMB(int size) async {
    // No-op
  }

  /// 指定默认的清晰度
  Future<void> setDefinition(String definition) async {
    // No-op
  }

  /// 当前位置移动到下一个
  Future<void> moveToNext(
      {String? accId, String? accKey, String? token, String? region}) async {
    // No-op
  }

  /// 当前位置移动到上一个
  Future<void> moveToPre({
    String? accId,
    String? accKey,
    String? token,
    String? region,
  }) async {
    // No-op
  }

  ///移动到指定位置开始准备播放
  Future<void> moveTo(
      {@required String? uid,
      String? accId,
      String? accKey,
      String? token,
      String? region}) async {
    // No-op
  }
}
