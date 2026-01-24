import 'package:flutter/services.dart';

class FlutterAliPlayerGlobalSettings {
  static const MethodChannel methodChannel =
      MethodChannel("plugins.flutter_global_setting");
  // ignore: unused_field
  static const EventChannel _eventChannel =
      EventChannel("plugins.flutter_global_setting_event");

  /// 国际站环境集成
  static Future<void> setGlobalEnvironment(int config) async {
    // No-op in pure Dart
  }

  /// 设置特定功能选项
  static Future<void> setOption(int opt1, Object opt2) async {
    // No-op in pure Dart
  }

  /// 播放器实例禁用crash堆栈上传
  static Future<void> disableCrashUpload(bool enable) async {
    // No-op in pure Dart
  }

  /// 是否开启增强型httpDNS
  static Future<void> enableEnhancedHttpDns(bool enable) async {
    // No-op in pure Dart
  }

  /// 开启大缓存功能
  static Future<void> enableBufferToLocalCache(bool enable) async {
    // No-op in pure Dart
  }
}
