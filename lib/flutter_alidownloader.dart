import 'package:flutter/services.dart';

class FlutterAliDownloader {
  MethodChannel _methodChannel = MethodChannel("plugins.flutter_alidownload");
  EventChannel _eventChannel =
      EventChannel("plugins.flutter_alidownload_event");

  Stream<dynamic>? _receiveStream;

  FlutterAliDownloader.init() {
    _receiveStream = _eventChannel.receiveBroadcastStream();
    //TODO iOS必须在这里监听 才能回调
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /// 准备下载
  ///type {FlutterAvpdef.DOWNLOADTYPE_STS / FlutterAvpdef.DOWNLOADTYPE_AUTH}
  ///STS {vid,accessKeyId,accessKeySecret,securityToken}
  ///AUTH {vid,playAuth}
  Future<dynamic> prepare(String type, String vid,
      {int? index,
      String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? playAuth}) async {
    var map = {
      'type': type,
      'vid': vid,
      'index': index,
      'region': region,
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'securityToken': securityToken,
      'playAuth': playAuth
    };
    return _methodChannel.invokeMethod("prepare", map);
  }

  /// 开始下载
  Stream<dynamic>? start(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    _methodChannel.invokeMethod("start", map);
    return _receiveStream;
  }

  /// 设置下载的trackIndex
  Future<dynamic> selectItem(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    return _methodChannel.invokeMethod("selectItem", map);
  }

  /// 设置下载的保存路径
  void setSaveDir(String path) {
    _methodChannel.invokeMethod("setSaveDir", path);
  }

  // iOS获取下载完成后保存的文件全路径
  // savePath：监听下载完成方法中EventChanneldef.DOWNLOAD_COMPLETION获取的'savePath'值
  Future<dynamic> getFullSaveForIOS(String savePath) {
    return _methodChannel.invokeMethod("getFullSaveDir", savePath);
  }

  /// 停止下载
  Future<dynamic> stop(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    return _methodChannel.invokeMethod("stop", map);
  }

  /// 删除下载文件
  Future<dynamic> delete(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    return _methodChannel.invokeMethod("delete", map);
  }

  /// 获取下载文件路径
  Future<dynamic> getFilePath(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    return _methodChannel.invokeMethod("getFilePath", map);
  }

  /// 销毁下载对象
  Future<dynamic> release(String vid, int index) {
    var map = {'vid': vid, 'index': index};
    return _methodChannel.invokeMethod("release", map);
  }

  /// 鉴权过期，更新下载源信息
  Future<dynamic> updateSource(String type, String vid, String index,
      {String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? playAuth}) {
    var map = {
      'type': type,
      'vid': vid,
      'index': index,
      'region': region,
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'securityToken': securityToken,
      'playAuth': playAuth
    };
    return _methodChannel.invokeMethod("updateSource", map);
  }

  /// 设置下载config
  Future<dynamic> setDownloaderConfig(String vid, String index,
      {String? userAgent,
      String? referrer,
      String? httpProxy,
      int? connectTimeoutS,
      int? networkTimeoutMs}) {
    var map = {
      'vid': vid,
      'index': index,
      'UserAgent': userAgent,
      'Referrer': referrer,
      'HttpProxy': httpProxy,
      'ConnectTimeoutS': connectTimeoutS,
      'NetworkTimeoutMs': networkTimeoutMs
    };
    return _methodChannel.invokeMethod("setDownloaderConfig", map);
  }

  void _onEvent(dynamic event) {}

  void _onError(dynamic error) {}
}
