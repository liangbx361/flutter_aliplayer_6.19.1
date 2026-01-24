import 'package:flutter/services.dart';

// ignore: unused_import
import 'flutter_avpdef.dart';

typedef OnMediaCompletion = void Function(String url);
typedef OnMediaError = void Function(String url, int code, String msg);
typedef OnMediaCancel = void Function(String url);

class FlutterAliPlayerMediaLoader {
  // ignore: unused_field
  static const MethodChannel methodChannel =
      MethodChannel("plugins.flutter_aliplayer_media_loader");
  // ignore: unused_field
  static const EventChannel eventChannel =
      EventChannel("flutter_aliplayer_media_loader_event");
  static FlutterAliPlayerMediaLoader? _instance;

  FlutterAliPlayerMediaLoader._() {
    // No-op in pure Dart
  }

  static FlutterAliPlayerMediaLoader _getInstance() {
    _instance ??= FlutterAliPlayerMediaLoader._();
    return _instance!;
  }

  factory FlutterAliPlayerMediaLoader() => _getInstance();

  OnMediaCompletion? onCompletion;
  OnMediaCancel? onCancel;
  OnMediaError? onError;

  /// 开始加载文件
  Future<void> load(String url, String duration) async {
    // No-op
  }

  /// 恢复加载
  Future<void> resume(String url) async {
    // No-op
  }

  /// 暂停加载
  Future<void> pause(String url) async {
    // No-op
  }

  /// 取消加载
  Future<void> cancel(String url) async {
    // No-op
  }

  /// 监听预加载相关回调
  void setOnLoadStatusListener(OnMediaCompletion? onCompletion,
      OnMediaCancel? onCancel, OnMediaError? onError) {
    this.onCompletion = onCompletion;
    this.onCancel = onCancel;
    this.onError = onError;
  }
}
