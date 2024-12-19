import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliliveshiftplayer.dart';

class FlutterAliPlayerFactory {
  static MethodChannel methodChannel =
      MethodChannel("plugins.flutter_aliplayer_factory");

  static Map<String, FlutterAliplayer> instanceMap = {};

  /// 创建短视频列表播放
  static FlutterAliListPlayer createAliListPlayer({playerId}) {
    FlutterAliListPlayer flutterAliListPlayer =
        FlutterAliListPlayer.init(playerId);
    flutterAliListPlayer.create();
    return flutterAliListPlayer;
  }

  /// 创建普通播放器
  static FlutterAliplayer createAliPlayer({playerId}) {
    FlutterAliplayer flutterAliplayer = FlutterAliplayer.init(playerId);
    flutterAliplayer.create();
    return flutterAliplayer;
  }

  static FlutterAliLiveShiftPlayer createAliLiveShiftPlayer({playerId}) {
    FlutterAliLiveShiftPlayer flutterAliLiveShiftPlayer =
        FlutterAliLiveShiftPlayer.init(playerId);
    flutterAliLiveShiftPlayer.create();
    return flutterAliLiveShiftPlayer;
  }

  /// 初始化下载秘钥信息
  static Future<void> initService(Uint8List byteData) {
    return methodChannel.invokeMethod("initService", byteData);
  }

  /// 初始化license证书服务
  /// 仅对iOS系统有效
  static Future<void> initLicenseServiceForIOS() {
    return methodChannel.invokeMethod("initLicenseServiceForIOS");
  }

  static void showFloatViewForAndroid(int viewId) {
    methodChannel.invokeMethod("showFloatViewForAndroid", viewId);
  }

  static void hideFloatViewForAndroid() {
    methodChannel.invokeMethod("hideFloatViewForAndroid");
  }

  /// 选择sdk
  static void loadRtsLibrary(bool isAliPlayerSDK) async {
    if (Platform.isAndroid) {
      methodChannel.invokeMethod("loadRtsLibrary", isAliPlayerSDK);
    }
  }
}
