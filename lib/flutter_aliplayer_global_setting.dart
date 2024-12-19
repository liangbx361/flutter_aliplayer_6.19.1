import 'package:flutter/services.dart';

class FlutterAliPlayerGlobalSettings {
  static MethodChannel methodChannel =
      MethodChannel("plugins.flutter_global_setting");
  static EventChannel _eventChannel =
      EventChannel("plugins.flutter_global_setting_event");

  /// 国际站环境集成
  static Future<void> setGlobalEnvironment(int config) {
    return methodChannel.invokeMethod("setGlobalEnvironment", config);
  }

  /// 设置特定功能选项
  static Future<void> setOption(int opt1, Object opt2) async {
    var map = {"opt1": opt1, "opt2": opt2};
    return methodChannel.invokeMethod("setOption", map);
  }

  /// 播放器实例禁用crash堆栈上传
  static Future<void> disableCrashUpload(bool enable) {
    return methodChannel.invokeMethod("disableCrashUpload", enable);
  }

  /// 是否开启增强型httpDNS
  /// 默认不开启 开启后需要注意以下事项
  /// 1.该功能与Httpdns互斥，若同时打开，后开启的功能会实际生效；
  /// 2.需要申请license的高级httpdns功能，否则该功能不工作
  /// 3.需要通过接口添加cdn域名，否则会降级至local dns。
  static Future<void> enableEnhancedHttpDns(bool enable) {
    return methodChannel.invokeMethod("enableEnhancedHttpDns", enable);
  }
}
