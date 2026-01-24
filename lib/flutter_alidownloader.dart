import 'package:flutter/services.dart';

class FlutterAliDownloader {
  // ignore: unused_field
  final MethodChannel _methodChannel =
      const MethodChannel("plugins.flutter_alidownload");
  // ignore: unused_field
  final EventChannel _eventChannel =
      const EventChannel("plugins.flutter_alidownload_event");

  Stream<dynamic>? _receiveStream;

  FlutterAliDownloader.init() {
    // No-op in pure Dart
  }

  /// 准备下载
  Future<dynamic> prepare(String type, String vid,
      {int? index,
      String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? playAuth}) async {
    return 0;
  }

  /// 开始下载
  Stream<dynamic>? start(String vid, int index) {
    return _receiveStream;
  }

  /// 设置下载的trackIndex
  Future<dynamic> selectItem(String vid, int index) async {
    return 0;
  }

  /// 设置下载的保存路径
  void setSaveDir(String path) {
    // No-op
  }

  // iOS获取下载完成后保存的文件全路径
  Future<dynamic> getFullSaveForIOS(String savePath) async {
    return savePath;
  }

  /// 停止下载
  Future<dynamic> stop(String vid, int index) async {
    return 0;
  }

  /// 删除下载文件
  Future<dynamic> delete(String vid, int index) async {
    return 0;
  }

  /// 获取下载文件路径
  Future<dynamic> getFilePath(String vid, int index) async {
    return "";
  }

  /// 销毁下载对象
  Future<dynamic> release(String vid, int index) async {
    return 0;
  }

  /// 鉴权过期，更新下载源信息
  Future<dynamic> updateSource(String type, String vid, String index,
      {String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? playAuth}) async {
    return 0;
  }

  /// 设置下载config
  Future<dynamic> setDownloaderConfig(String vid, String index,
      {String? userAgent,
      String? referrer,
      String? httpProxy,
      int? connectTimeoutS,
      int? networkTimeoutMs}) async {
    return 0;
  }
}
