import 'dart:typed_data';

import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliliveshiftplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_mock.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_mock_ext.dart';

class FlutterAliPlayerFactory {
  static Map<String, FlutterAliplayer> instanceMap = {};

  /// 创建短视频列表播放
  static FlutterAliListPlayer createAliListPlayer({playerId}) {
    return FlutterAliListPlayerMock.init(playerId);
  }

  /// 创建普通播放器
  static FlutterAliplayer createAliPlayer({playerId}) {
    return FlutterAliplayerMock.init(playerId);
  }

  static FlutterAliLiveShiftPlayer createAliLiveShiftPlayer({playerId}) {
    return FlutterAliLiveShiftPlayerMock.init(playerId);
  }

  /// 初始化下载秘钥信息
  static Future<void> initService(Uint8List byteData) {
    return Future.value();
  }

  /// 初始化license证书服务
  /// 仅对iOS系统有效
  static Future<void> initLicenseServiceForIOS() {
    return Future.value();
  }

  static void showFloatViewForAndroid(int viewId) {
    // No-op
  }

  static void hideFloatViewForAndroid() {
    // No-op
  }

  /// 选择sdk
  static void loadRtsLibrary(bool isAliPlayerSDK) async {
    // No-op
  }
}
