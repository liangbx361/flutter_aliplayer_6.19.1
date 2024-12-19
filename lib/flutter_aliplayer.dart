import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';

export 'flutter_avpdef.dart';

typedef OnPrepared = void Function(String playerId);

typedef OnRenderingStart = void Function(String playerId);
typedef OnVideoSizeChanged = void Function(
    int width, int height, int? rotation, String playerId);
typedef OnSnapShot = void Function(String path, String playerId);
typedef OnSeekComplete = void Function(String playerId);
typedef OnSeiData = void Function(
    int type, Uint8List uuid, Uint8List data, String playerId);

typedef OnLoadingBegin = void Function(String playerId);
typedef OnLoadingProgress = void Function(
    int percent, double? netSpeed, String playerId);
typedef OnLoadingEnd = void Function(String playerId);

typedef OnStateChanged = void Function(int newState, String playerId);

typedef OnSubtitleExtAdded = void Function(
    int trackIndex, String url, String playerId);
typedef OnSubtitleShow = void Function(
    int trackIndex, int subtitleID, String subtitle, String playerId);
typedef OnSubtitleHide = void Function(
    int trackIndex, int subtitleID, String playerId);
typedef OnSubtitleHeader = void Function(
    int trackIndex, String head, String playerId);
typedef OnTrackReady = void Function(String playerId);
typedef OnVideoRendered = void Function(int? timeMs, int? pts, String playerId);
typedef OnInfo = void Function(
    int? infoCode, int? extraValue, String? extraMsg, String playerId);
typedef OnError = void Function(
    int errorCode, String? errorExtra, String? errorMsg, String playerId);
typedef OnCompletion = void Function(String playerId);

typedef OnTrackChanged = void Function(dynamic value, String playerId);

typedef OnThumbnailPreparedSuccess = void Function(String playerId);
typedef OnThumbnailPreparedFail = void Function(String playerId);

typedef OnThumbnailGetSuccess = void Function(
    Uint8List bitmap, Int64List range, String playerId);
typedef OnThumbnailGetFail = void Function(String playerId);

typedef OnSeekLiveCompletion = void Function(int playTime, String playerId);
typedef OnTimeShiftUpdater = void Function(
    int currentTime, int shiftStartTime, int shiftEndTime, String playerId);

typedef OnEventReportParams = void Function(Map params, String playerId);
typedef OnPipStatusChanged = void Function(bool playing, String playerId);
typedef OnWillStartPip = void Function(bool pipStatus, String playerId);
typedef OnWillStopPip = void Function(bool pipStatus, String playerId);

class FlutterAliplayer {
  OnPipStatusChanged? onPipStatusChanged;
  OnWillStartPip? onWillStartPip;
  OnWillStopPip? onWillStopPip;
  OnLoadingBegin? onLoadingBegin;
  OnLoadingProgress? onLoadingProgress;
  OnLoadingEnd? onLoadingEnd;
  OnPrepared? onPrepared;
  OnRenderingStart? onRenderingStart;
  OnVideoSizeChanged? onVideoSizeChanged;
  OnSeekComplete? onSeekComplete;
  OnStateChanged? onStateChanged;
  OnInfo? onInfo;
  OnCompletion? onCompletion;
  OnTrackReady? onTrackReady;
  OnVideoRendered? onVideoRendered;
  OnError? onError;
  OnSeiData? onSeiData;
  OnSnapShot? onSnapShot;
  OnTrackChanged? onTrackChanged;
  OnThumbnailPreparedSuccess? onThumbnailPreparedSuccess;
  OnThumbnailPreparedFail? onThumbnailPreparedFail;

  OnThumbnailGetSuccess? onThumbnailGetSuccess;
  OnThumbnailGetFail? onThumbnailGetFail;

  //外挂字幕
  OnSubtitleExtAdded? onSubtitleExtAdded;
  OnSubtitleHide? onSubtitleHide;
  OnSubtitleShow? onSubtitleShow;
  OnSubtitleHeader? onSubtitleHeader;

  //直播时移
  OnSeekLiveCompletion? onSeekLiveCompletion;
  OnTimeShiftUpdater? onTimeShiftUpdater;

  //埋点
  OnEventReportParams? onEventReportParams;

  // static MethodChannel channel = new MethodChannel('flutter_aliplayer');
  EventChannel eventChannel = EventChannel("flutter_aliplayer_event");

  String playerId = 'default';

  FlutterAliplayer.init(String? id) {
    if (id != null) {
      playerId = id;
    }
    FlutterAliPlayerFactory.instanceMap[playerId] = this;
    register();
  }

  void register() {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /// 播放器事件回调，准备完成事件
  void setOnPrepared(OnPrepared prepared) {
    this.onPrepared = prepared;
  }

  /// 播放器事件回调，首帧显示事件
  void setOnRenderingStart(OnRenderingStart renderingStart) {
    this.onRenderingStart = renderingStart;
  }

  /// 视频大小变化回调
  void setOnVideoSizeChanged(OnVideoSizeChanged videoSizeChanged) {
    this.onVideoSizeChanged = videoSizeChanged;
  }

  /// 获取截图回调
  void setOnSnapShot(OnSnapShot snapShot) {
    this.onSnapShot = snapShot;
  }

  // 播放器事件回调，跳转完成事件
  void setOnSeekComplete(OnSeekComplete seekComplete) {
    this.onSeekComplete = seekComplete;
  }

  /// 错误代理回调
  void setOnError(OnError onError) {
    this.onError = onError;
  }

  /// SEI回调
  void setOnSeiData(OnSeiData seiData) {
    this.onSeiData = seiData;
  }

  /// 视频缓冲相关回调
  /// loadingBegin: 播放器事件回调，缓冲开始事件
  /// loadingProgress: 视频缓冲进度回调
  /// loadingEnd: 播放器事件回调，缓冲完成事件
  void setOnLoadingStatusListener(
      {required OnLoadingBegin loadingBegin,
      required OnLoadingProgress loadingProgress,
      required OnLoadingEnd loadingEnd}) {
    this.onLoadingBegin = loadingBegin;
    this.onLoadingProgress = loadingProgress;
    this.onLoadingEnd = loadingEnd;
  }

  /// 画中画播放状态
  /// pipStatusChanged：播放器状态
  /// willStartPip：画中画将要开始
  /// willStopPip：画中画将要结束
  void setPipController(
      {required OnPipStatusChanged pipStatusChanged,
      required OnWillStartPip willStartPip,
      required OnWillStopPip willStopPip}) {
    this.onPipStatusChanged = pipStatusChanged;
    this.onWillStartPip = willStartPip;
    this.onWillStopPip = willStopPip;
  }

  /// 播放器状态改变回调
  void setOnStateChanged(OnStateChanged stateChanged) {
    this.onStateChanged = stateChanged;
  }

  /// 视频当前播放位置回调
  void setOnInfo(OnInfo info) {
    this.onInfo = info;
  }

  /// 播放器事件回调，播放完成事件
  void setOnCompletion(OnCompletion completion) {
    this.onCompletion = completion;
  }

  /// 获取track信息回调
  void setOnTrackReady(OnTrackReady onTrackReady) {
    this.onTrackReady = onTrackReady;
  }

  /// 播放器渲染信息回调
  void setOnVideoRendered(OnVideoRendered onVideoRendered) {
    this.onVideoRendered = onVideoRendered;
  }

  /// track切换完成回调
  void setOnTrackChanged(OnTrackChanged onTrackChanged) {
    this.onTrackChanged = onTrackChanged;
  }

  void setOnThumbnailPreparedListener(
      {required OnThumbnailPreparedSuccess preparedSuccess,
      required OnThumbnailPreparedFail preparedFail}) {
    this.onThumbnailPreparedSuccess = preparedSuccess;
    this.onThumbnailPreparedFail = preparedFail;
  }

  /// 获取缩略图相关回调
  /// onThumbnailGetSuccess: 获取缩略图成功回调
  /// onThumbnailGetFail: 获取缩略图失败回调
  void setOnThumbnailGetListener(
      {required OnThumbnailGetSuccess onThumbnailGetSuccess,
      required OnThumbnailGetFail onThumbnailGetFail}) {
    this.onThumbnailGetSuccess = onThumbnailGetSuccess;
    this.onThumbnailGetSuccess = onThumbnailGetSuccess;
  }

  /// 字幕显示回调
  void setOnSubtitleShow(OnSubtitleShow onSubtitleShow) {
    this.onSubtitleShow = onSubtitleShow;
  }

  /// 字幕隐藏回调
  void setOnSubtitleHide(OnSubtitleHide onSubtitleHide) {
    this.onSubtitleHide = onSubtitleHide;
  }

  /// 字幕头信息回调
  /// ass字幕，如果实现了此回调，则播放器不会渲染字幕，由调用者完成渲染，否则播放器自动完成字幕的渲染
  void setOnSubtitleHeader(OnSubtitleHeader onSubtitleHeader) {
    this.onSubtitleHeader = onSubtitleHeader;
  }

  /// 外挂字幕被添加
  void setOnSubtitleExtAdded(OnSubtitleExtAdded onSubtitleExtAdded) {
    this.onSubtitleExtAdded = onSubtitleExtAdded;
  }

  void setOnSeekLiveCompletion(OnSeekLiveCompletion seekLiveCompletion) {
    this.onSeekLiveCompletion = seekLiveCompletion;
  }

  void setOnTimeShiftUpdater(OnTimeShiftUpdater timeShiftUpdater) {
    this.onTimeShiftUpdater = timeShiftUpdater;
  }

  /// 埋点事件参数回调
  void setOnEventReportParams(OnEventReportParams eventReportParams) {
    this.onEventReportParams = eventReportParams;
  }

  ///接口部分
  wrapWithPlayerId({arg = ''}) {
    var map = {"arg": arg, "playerId": this.playerId.toString()};
    return map;
  }

  /// 创建播放器
  Future<void> create() async {
    var invokeMethod = FlutterAliPlayerFactory.methodChannel.invokeMethod(
        'createAliPlayer', wrapWithPlayerId(arg: PlayerType.PlayerType_Single));
    // sendCustomEvent("source=flutter");
    return invokeMethod;
  }

  /// 设置播放器的视图playerView
  Future<void> setPlayerView(int viewId) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setPlayerView', wrapWithPlayerId(arg: viewId));
  }

  /// 使用url方式来播放视频
  Future<void> setUrl(String url) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setUrl', wrapWithPlayerId(arg: url));
  }

  /// 播放准备
  Future<void> prepare() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('prepare', wrapWithPlayerId());
  }

  /// 开始播放
  Future<void> play() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('play', wrapWithPlayerId());
  }

  /// 暂停播放
  Future<void> pause() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('pause', wrapWithPlayerId());
  }

  /// 清空画面
  Future<void> clearScreen() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('clearScreen', wrapWithPlayerId());
  }

  /// 清空同步画面
  Future<void> clearScreenSync() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('clearScreenSync', wrapWithPlayerId());
  }

  /// 截图
  /// 信息可在获取截图回调中取得
  Future<dynamic> snapshot(String path) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('snapshot', wrapWithPlayerId(arg: path));
  }

  /// 停止播放
  Future<void> stop() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('stop', wrapWithPlayerId());
  }

  /// 销毁播放器
  Future<void> destroy() async {
    FlutterAliPlayerFactory.instanceMap.remove(playerId);
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('destroy', wrapWithPlayerId());
  }

  /// 异步释放播放器
  Future<void> releaseAsync() async {
    FlutterAliPlayerFactory.instanceMap.remove(playerId);
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('releaseAsync', wrapWithPlayerId());
  }

  /// 跳转到指定的播放位置
  Future<void> seekTo(int position, int seekMode) async {
    var map = {"position": position, "seekMode": seekMode};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("seekTo", wrapWithPlayerId(arg: map));
  }

  /// 以指定位置起播，每次prepare前调用，仅生效一次。（用于代替原先的起播前seek的方案）
  Future<void> setStartTime(int time, int seekMode) async {
    var map = {"time": time, "seekMode": seekMode};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setStartTime", wrapWithPlayerId(arg: map));
  }

  /// 设置特定功能选项
  Future<void> setOption(int opt1, Object opt2) async {
    var map = {"opt1": opt1, "opt2": opt2};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setOption", wrapWithPlayerId(arg: map));
  }

  /// 设置精准seek的最大间隔
  Future<void> setMaxAccurateSeekDelta(int delta) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setMaxAccurateSeekDelta", wrapWithPlayerId(arg: delta));
  }

  /// 当前是否循环播放
  Future<dynamic> isLoop() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isLoop', wrapWithPlayerId());
  }

  /// 设置是否循环播放
  Future<void> setLoop(bool isloop) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setLoop', wrapWithPlayerId(arg: isloop));
  }

  /// 当前是否自动播放
  Future<dynamic> isAutoPlay() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isAutoPlay', wrapWithPlayerId());
  }

  /// 设置是否自动播放
  Future<void> setAutoPlay(bool isAutoPlay) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setAutoPlay', wrapWithPlayerId(arg: isAutoPlay));
  }

  /// 设置视频快速启动
  Future<void> setFastStart(bool fastStart) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setFastStart", wrapWithPlayerId(arg: fastStart));
  }

  /// 当前是否静音
  Future<dynamic> isMuted() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('isMuted', wrapWithPlayerId());
  }

  /// 设置是否静音
  Future<void> setMuted(bool isMuted) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setMuted', wrapWithPlayerId(arg: isMuted));
  }

  /// 当前是否开启硬件解码
  Future<dynamic> enableHardwareDecoder() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('enableHardwareDecoder', wrapWithPlayerId());
  }

  /// 设置是否开启硬件解码
  Future<void> setEnableHardwareDecoder(bool isHardWare) async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        'setEnableHardwareDecoder', wrapWithPlayerId(arg: isHardWare));
  }

  /// 软解码时生效，是否只返回底层音频数据地址，mAudioDataAddr默认为false,
  /// 是否只返回底层视频数据地址，默认为true
  Future<void> setRenderFrameCallbackConfig(
      bool mAudioData, bool mVideoData) async {
    var map = {"mAudioData": mAudioData, "mVideoData": mVideoData};
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        'setRenderFrameCallbackConfig', wrapWithPlayerId(arg: map));
  }

  /// 用vid和sts来播放视频
  /// sts可参考：https://help.aliyun.com/document_detail/28756.html?spm=a2c4g.11186623.4.4.6f554c07q7B7aS
  /// playConfig 从[generatePlayerConfig]获取
  Future<void> setVidSts(
      {String? vid,
      String? region,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? playConfig,
      List<String>? definitionList,
      String quality = "",
      bool forceQuality = false,
      playerId}) async {
    Map<String, dynamic> stsInfo = {
      "vid": vid,
      "region": region,
      "accessKeyId": accessKeyId,
      "accessKeySecret": accessKeySecret,
      "securityToken": securityToken,
      "definitionList": definitionList,
      "playConfig": playConfig,
      "quality": quality,
      "forceQuality": forceQuality
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidSts", wrapWithPlayerId(arg: stsInfo));
  }

  /// 使用vid+playauth方式播放
  /// 可参考：https://help.aliyun.com/document_detail/57294.html
  /// playConfig 从[generatePlayerConfig]获取
  Future<void> setVidAuth(
      {String? vid,
      String? region,
      String? playAuth,
      String? playConfig,
      List<String>? definitionList,
      String quality = "",
      bool forceQuality = false,
      playerId}) async {
    Map<String, dynamic> authInfo = {
      "vid": vid,
      "region": region,
      "playAuth": playAuth,
      "definitionList": definitionList,
      "playConfig": playConfig,
      "quality": quality,
      "forceQuality": forceQuality
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidAuth", wrapWithPlayerId(arg: authInfo));
  }

  /// 用vid和MPS信息来播放视频
  /// 可参考：https://help.aliyun.com/document_detail/53522.html?spm=5176.doc53534.2.5.mhSfOh
  Future<void> setVidMps(Map<String, dynamic> mpsInfo) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setVidMps", wrapWithPlayerId(arg: mpsInfo));
  }

  /// 使用LiveSts 方式播放直播流
  Future<void> setLiveSts(
      {String? url,
      String? accessKeyId,
      String? accessKeySecret,
      String? securityToken,
      String? region,
      String? domain,
      String? app,
      String? stream,
      EncryptionType? encryptionType,
      List<String>? definitionList,
      playerId}) async {
    Map<String, dynamic> liveStsInfo = {
      "url": url,
      "accessKeyId": accessKeyId,
      "accessKeySecret": accessKeySecret,
      "securityToken": securityToken,
      "region": region,
      "domain": domain,
      "app": app,
      "stream": stream,
      "encryptionType": encryptionType?.index.toString(),
      "definitionList": definitionList,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setLiveSts", wrapWithPlayerId(arg: liveStsInfo));
  }

  /// 更新LiveSts信息
  Future<dynamic> updateLiveStsInfo(
      String accId, String accKey, String token, String region) async {
    Map<String, String> liveStsInfo = {
      "accId": accId,
      "accKey": accKey,
      "token": token,
      "region": region,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('updateLiveStsInfo', wrapWithPlayerId(arg: liveStsInfo));
  }

  /// 获取渲染旋转模式
  Future<dynamic> getRotateMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getRotateMode', wrapWithPlayerId());
  }

  /// 设置渲染旋转模式
  Future<void> setRotateMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setRotateMode', wrapWithPlayerId(arg: mode));
  }

  /// 获取渲染填充模式
  Future<dynamic> getScalingMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getScalingMode', wrapWithPlayerId());
  }

  /// 设置渲染填充模式
  Future<void> setScalingMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setScalingMode', wrapWithPlayerId(arg: mode));
  }

  /// 设置输出声道，若输入源是双声道，则支持切换为左声道、右声道；若输入源是单声道，则设置无效。该设置会同时影响音频渲染及PCM数据回调
  Future<void> setOutputAudioChannel(int chanel) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setOutputAudioChannel', wrapWithPlayerId(arg: chanel));
  }

  /// 获取渲染镜像模式
  Future<dynamic> getMirrorMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getMirrorMode', wrapWithPlayerId());
  }

  /// 获取Alpha渲染模式
  Future<dynamic> getAlphaRenderMode() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getAlPhaRenderMode', wrapWithPlayerId());
  }

  /// Alpha渲染模式，支持alpha在右侧、左侧、上侧、下侧，默认值无
  Future<void> setAlphaRenderMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setAlphaRenderMode', wrapWithPlayerId(arg: mode));
  }

  /// 设置渲染镜像模式
  Future<void> setMirrorMode(int mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setMirrorMode', wrapWithPlayerId(arg: mode));
  }

  /// 获取播放速率
  Future<dynamic> getRate() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getRate', wrapWithPlayerId());
  }

  /// 设置播放速率
  /// 0.5-2.0之间，1为正常播放
  Future<void> setRate(double mode) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setRate', wrapWithPlayerId(arg: mode));
  }

  /// 设置视频的背景色
  Future<void> setVideoBackgroundColor(var color) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setVideoBackgroundColor', wrapWithPlayerId(arg: color));
  }

  /// 获取视频的宽度
  Future<dynamic> getVideoWidth() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVideoWidth', wrapWithPlayerId());
  }

  /// 获取视频的高度
  Future<dynamic> getVideoHeight() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVideoHeight', wrapWithPlayerId());
  }

  /// 获取视频的旋转角度
  Future<dynamic> getVideoRotation() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVideoRotation', wrapWithPlayerId());
  }

  /// 设置播放器的音量（非系统音量）
  /// 范围0.0~2.0，当音量大于1.0时，可能出现噪音，不推荐使用
  Future<void> setVolume(double volume) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setVolume', wrapWithPlayerId(arg: volume));
  }

  /// 获取播放器的音量（非系统音量）
  Future<dynamic> getVolume() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getVolume', wrapWithPlayerId());
  }

  /// 获取视频的长度
  Future<dynamic> getDuration() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getDuration', wrapWithPlayerId());
  }

  /// 获取当前播放位置
  Future<dynamic> getCurrentPosition() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentPosition', wrapWithPlayerId());
  }

  /// 获取当前播放位置的utc时间
  Future<dynamic> getCurrentUtcTime() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentUtcTime', wrapWithPlayerId());
  }

  /// 获取当前播放命中的缓存文件大小
  Future<dynamic> getLocalCacheLoadedSize() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getLocalCacheLoadedSize', wrapWithPlayerId());
  }

  /// 获取当前下载速度
  Future<dynamic> getCurrentDownloadSpeed() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentDownloadSpeed', wrapWithPlayerId());
  }

  /// 获取已经缓存的位置
  Future<dynamic> getBufferedPosition() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getBufferedPosition', wrapWithPlayerId());
  }

  /// 获取播放器设置
  Future<dynamic> getConfig() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getConfig", wrapWithPlayerId());
  }

  /// 获取播放器设置
  /// 新版本增加，逐步替代[getConfig]
  Future<AVPConfig> getPlayConfig() async {
    Map map = await FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getPlayConfig", wrapWithPlayerId());
    return AVPConfig.convertAt(map);
  }

  /// 播放器设置，传递map
  Future<void> setConfig(Map map) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setConfig", wrapWithPlayerId(arg: map));
  }

  /// 播放器设置
  /// 新版本增加，逐步替代[setConfig]
  Future<void> setPlayConfig(AVPConfig config) async {
    Map map = config.convertToMap();
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPlayConfig", wrapWithPlayerId(arg: map));
  }

  /// 播放器降级设置
  /// source 降级url
  /// config 降级配置
  Future<void> enableDowngrade(String source, AVPConfig config) async {
    Map map = {
      "source": source,
      "config": config.convertToMap(),
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableDowngrade", wrapWithPlayerId(arg: map));
  }

  Future<dynamic> getCacheConfig() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCacheConfig", wrapWithPlayerId());
  }

  /// 设置缓存配置
  Future<void> setCacheConfig(Map map) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setCacheConfig", wrapWithPlayerId(arg: map));
  }

  /// 设置滤镜配置
  /// 在prepare之前调用此方法。如果想更新，调用updateFilterConfig
  Future<void> setFilterConfig(String configJson) async {
    // configJson格式: "[{"target":"<target1>", "options":["<options_key>"]}, {"target":"<target2>", "options":<null>},...]"
    // options_key 目前有两种"sharp"、"sr"
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setFilterConfig", wrapWithPlayerId(arg: configJson));
  }

  /// 更新滤镜配置
  Future<void> updateFilterConfig(String target, Map options) async {
    var map = {'target': target, 'options': options};
    // options格式: {"key":"<options_key>", "value": "<options_value>"}
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("updateFilterConfig", wrapWithPlayerId(arg: map));
  }

  /// 开启关闭滤镜
  Future<void> setFilterInvalid(String target, String invalid) async {
    var map = {'target': target, 'invalid': invalid};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setFilterInvalid", wrapWithPlayerId(arg: map));
  }

  /// 根据url获取缓存的文件名
  Future<dynamic> getCacheFilePath(String url) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCacheFilePath", wrapWithPlayerId(arg: url));
  }

  /// 根据vid获取缓存的文件名
  Future<dynamic> getCacheFilePathWithVid(
      String vid, String format, String definition) async {
    var map = {'vid': vid, 'format': format, 'definition': definition};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCacheFilePathWithVid", wrapWithPlayerId(arg: map));
  }

  /// 根据vid+试看时长获取缓存的文件名
  Future<dynamic> getCacheFilePathWithVidAtPreviewTime(
      String vid, String format, String definition, String previewTime) async {
    var map = {
      'vid': vid,
      'format': format,
      'definition': definition,
      'previewTime': previewTime
    };
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "getCacheFilePathWithVidAtPreviewTime", wrapWithPlayerId(arg: map));
  }

  /// 获取媒体信息，包括track信息
  Future<dynamic> getMediaInfo() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getMediaInfo", wrapWithPlayerId());
  }

  /// 获取媒体子流信息，包括track信息
  Future<dynamic> getSubMediaInfo() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getSubMediaInfo", wrapWithPlayerId());
  }

  /// 获取当前播放track
  Future<dynamic> getCurrentTrack(int trackIdx) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getCurrentTrack", wrapWithPlayerId(arg: trackIdx));
  }

  /// 设置缩略图URL
  Future<dynamic> createThumbnailHelper(String thumbnail) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "createThumbnailHelper", wrapWithPlayerId(arg: thumbnail));
  }

  /// 播放前转换播放URL。
  /// 对于视频播放，请在播放前尝试转换播放URL
  Future<dynamic> setConvertURLCallback(String newUrl) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "createFrameCallbackHelper", wrapWithPlayerId(arg: newUrl));
  }

  /// 获取指定位置的缩略图
  Future<dynamic> requestBitmapAtPosition(int position) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "requestBitmapAtPosition", wrapWithPlayerId(arg: position));
  }

  /// 设置traceID，用于跟踪debug信息
  /// 通过埋点事件回调onEventReportParams
  Future<dynamic> setTraceID(String traceID) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setTraceID", wrapWithPlayerId(arg: traceID));
  }

  /// 添加外挂字幕
  Future<void> addExtSubtitle(String url) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addExtSubtitle", wrapWithPlayerId(arg: url));
  }

  /// 选择外挂字幕
  Future<void> selectExtSubtitle(int trackIndex, bool enable) {
    var map = {'trackIndex': trackIndex, 'enable': enable};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("selectExtSubtitle", wrapWithPlayerId(arg: map));
  }

  /// 设置多码率时默认播放的码率
  /// 将会选择与之最接近的一路流播放
  Future<void> setDefaultBandWidth(int parse) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setDefaultBandWidth", wrapWithPlayerId(arg: parse));
  }

  /// 根据trackIndex，切换清晰度
  /// trackIdx 选择清晰度的index，-1代表自适应码率
  ///  accurate 0 为不精确  1 为精确  不填为忽略
  Future<void> selectTrack(
    int trackIdx, {
    int accurate = -1,
  }) {
    var map = {
      'trackIdx': trackIdx,
      'accurate': accurate,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("selectTrack", wrapWithPlayerId(arg: map));
  }

  Future<void> setPrivateService(Int8List data) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPrivateService", data);
  }

  /// 设置期望使用的播放器名字
  Future<void> setPreferPlayerName(String playerName) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPreferPlayerName", wrapWithPlayerId(arg: playerName));
  }

  /// 为画中画功能设置显示模式
  Future<void> setPictureInPictureShowMode(int showMode) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "setPictureInPictureShowMode", wrapWithPlayerId(arg: showMode));
  }

  /// 获取播放时使用的播放器名字
  Future<dynamic> getPlayerName() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getPlayerName", wrapWithPlayerId());
  }

  /// 发送用户自定义事件
  /// 通过埋点事件回调onEventReportParams
  Future<void> sendCustomEvent(String args) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("sendCustomEvent", wrapWithPlayerId(arg: args));
  }

  /// 设置UserData，用于一些全局API的透传，以区分player实例。
  Future<void> setUserData(String userData) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setUserData", wrapWithPlayerId(arg: userData));
  }

  /// 设置UserData，用于一些全局API的透传，以区分player实例。
  Future<dynamic> getUserData() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getUserData", wrapWithPlayerId());
  }

  /// 设置某路流相对于主时钟的延时时间
  /// 默认是0, 目前只支持外挂字幕
  Future<void> setStreamDelayTime(int trackIdx, int time) {
    var map = {'index': trackIdx, 'time': time};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setStreamDelayTime", wrapWithPlayerId(arg: map));
  }

  /// 重新加载
  /// 比如网络超时时，可以重新加载。
  Future<void> reload() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('reload', wrapWithPlayerId());
  }

  /// 获取播放器的参数
  Future<dynamic> getOption(AVPOption key) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("getOption", wrapWithPlayerId(arg: key.index.toString()));
  }

  /// 根据key获取相应的信息
  Future<dynamic> getPropertyString(AVPPropertyKey key) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "getPropertyString", wrapWithPlayerId(arg: key.index.toString()));
  }

  /// 设置埋点事件回调onEventReportParams代理
  Future<dynamic> setEventReportParamsDelegate(int argt) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "setEventReportParamsDelegate", wrapWithPlayerId(arg: argt.toString()));
  }

  /// 设置画中画功能开启/关闭
  /// 仅对iOS系统有效，在iOS 15以上系统应用
  /// 需要在onPrepared回调方法中调用
  Future<dynamic> setPictureInPictureEnableForIOS(bool enable) {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
        "setPictureInPictureEnableForIOS",
        wrapWithPlayerId(arg: enable.toString()));
  }

  ///静态方法
  /// 获取SDK版本号信息
  static Future<dynamic> getSDKVersion() async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod("getSDKVersion");
  }

  /// 获取设备UUID
  static Future<dynamic> getDeviceUUID() async {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod("getDeviceUUID");
  }

  /// 返回某项功能是否支持
  /// type 是否支持的功能的类型。 参考SupportFeatureType。
  static Future<bool> isFeatureSupport(SupportFeatureType type) async {
    bool boolV = await FlutterAliPlayerFactory.methodChannel
        .invokeMethod("isFeatureSupport", type.index);
    return boolV;
  }

  /// 控制音频设置
  /// 默认按照播放器SDK自身设置，只对iOS平台有效
  /// 替代旧版本的[enableMix]
  static Future<void> setAudioSessionTypeForIOS(
      AliPlayerAudioSesstionType type) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setAudioSessionTypeForIOS", type.index);
  }

  /// 是否打开log输出
  static Future<void> enableConsoleLog(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableConsoleLog", enable);
  }

  /// 设置日志打印回调block
  /// logLevel log输出级别
  static Future<void> setLogLevel(int level) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setLogLevel", level);
  }

  /// 当播放H265流硬解失败且已设置H264备流时，实现自动降级播放H264备流；若未设置H264备流，则自动降级为H265软解播放
  static Future<void> setAdaptiveDecoderGetBackupURLCallback() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setAdaptiveDecoderGetBackupURLCallback");
  }

  /// 获取日志级别
  /// 仅对Android系统有效
  static Future<dynamic> getLogLevel() {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod(
      "getLogLevel",
    );
  }

  /// 设置是否使用http2
  static Future<void> setUseHttp2(bool use) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setUseHttp2", use);
  }

  /// 是否开启httpDNS
  /// 默认不开启
  static Future<void> enableHttpDns(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableHttpDns", enable);
  }

  /// 设置域名对应的解析ip
  /// host 域名，需指定端口（http默认端口80，https默认端口443）。例如player.alicdn.com:443
  /// ip 相应的ip，设置为空字符串清空设定。
  static Future<void> setDNSResolve(String host, String ip) {
    Map map = {
      "host": host,
      "ip": ip,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setDNSResolve", map);
  }

  /// 设置解析ip类型
  static Future<void> setIpResolveType(AVPIpResolveType type) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setIpResolveType", type.index.toString());
  }

  /// 设置fairPlay的用户证书id
  /// 仅对iOS系统有效
  static Future<void> setFairPlayCertIDForIOS(String certID) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setFairPlayCertIDForIOS", certID);
  }

  /// 设置是否使能硬件提供的音频变速播放能力
  /// 关闭后则使用软件实现音频的倍速播放，pcm回调数据的格式和此设置关联；默认打开
  static Future<void> enableHWAduioTempo(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableHWAduioTempo", enable);
  }

  /// 强制音频渲染器采用指定的格式进行渲染
  /// 如果设定的格式设备不支持，则无效，无效值将被忽略，使用默认值；pcm回调数据的格式和此设置关联；默认关闭
  static Future<void> forceAudioRendingFormat(
      String force, String fmt, String channels, String sample_rate) {
    var map = {
      'force': force,
      'fmt': fmt,
      'channels': channels,
      'sample_rate': sample_rate
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("forceAudioRendingFormat", map);
  }

  /// 重连所有网络连接
  /// 网络路由发生变化后，调用此接口，可以让播放器所有的连接切换到新的路由上去。
  static Future<void> netWorkReConnect() {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("netWorkReConnect");
  }

  /// 开启本地缓存
  /// 开启之后，就会缓存到本地文件中。
  static Future<void> enableLocalCache(bool enable, String maxBufferMemoryKB,
      String localCacheDir, DocTypeForIOS docTypeForIOS) {
    var map = {
      'enable': enable,
      'maxBufferMemoryKB': maxBufferMemoryKB,
      'localCacheDir': localCacheDir,
    };

    if (Platform.isIOS) {
      // docTypeForIOS的取值代表沙盒目录路径类型 "0":Documents, "1":Library, "2":Caches, 其他:Documents
      map['docTypeForIOS'] = docTypeForIOS.index.toString();
    } else {
      // 安卓不需设置docType，直接传递localCacheDir
    }

    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableLocalCache", map);
  }

  /// 本地缓存文件自动清理相关的设置
  static Future<void> setCacheFileClearConfig(
      String expireMin, String maxCapacityMB, String freeStorageMB) {
    var map = {
      'expireMin': expireMin,
      'maxCapacityMB': maxCapacityMB,
      'freeStorageMB': freeStorageMB,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setCacheFileClearConfig", map);
  }

  /// 是否开启内建预加载网络平衡策略，播放过程中，自动控制预加载的运行时机。默认开启。
  /// enable 是否开启
  static Future<void> enableNetworkBalance(bool enable) {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("enableNetworkBalance", enable);
  }

  /// 清理本地缓存，需要先应用配置缓存，才能清理本地缓存
  static Future<void> clearCaches() {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod("clearCaches");
  }

  ///return deviceInfo
  static Future<dynamic> createDeviceInfo() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("createDeviceInfo");
  }

  ///type : {FlutterAvpdef.BLACK_DEVICES_H264 / FlutterAvpdef.BLACK_DEVICES_HEVC}
  static Future<void> addBlackDevice(String type, String model) async {
    var map = {
      'black_type': type,
      'black_device': model,
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addBlackDevice", map);
  }

  /// 创建媒体播放自定义设置对象
  static Future<void> createVidPlayerConfigGenerator() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("createVidPlayerConfigGenerator");
  }

  /// 设置预览时间
  /// previewTime 预览时间，单位为秒
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  static Future<void> setPreviewTime(int previewTime) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setPreviewTime", previewTime.toString());
  }

  /// HLS标准加密设置UriToken
  /// mtsHlsUriToken 字符串
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  static Future<void> setHlsUriToken(String mtsHlsUriToken) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setHlsUriToken", mtsHlsUriToken);
  }

  /// 添加vid的playerconfig参数
  /// key: 对应playerConfig中的参数名字
  /// value: 对应key参数的值
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  /// Android 设置加密类型：key 为 EncryptType，value 可选：Unencrypted，AliyunVoDEncryption，HLSEncryption
  static Future<void> addVidPlayerConfigByStringValue(
      String key, String value) async {
    Map param = {key: value};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addVidPlayerConfigByStringValue", param);
  }

  /// 添加vid的playerconfig参数
  /// key: 对应playerConfig中的参数名字
  /// value: 对应key参数的整形值
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  static Future<void> addVidPlayerConfigByIntValue(
      String key, int value) async {
    Map param = {key: value.toString()};
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("addVidPlayerConfigByIntValue", param);
  }

  /// 添加vid的playerconfig参数
  /// 加密类型 EncryptType
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  static Future<void> setEncryptType(EncryptType type) async {
    int encryptType = EncryptType.values.indexOf(type);
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod("setEncryptType", encryptType);
  }

  /// 生成playerConfig
  /// 调用之前必须先执行[createVidPlayerConfigGenerator]
  static Future<String> generatePlayerConfig() async {
    return await FlutterAliPlayerFactory.methodChannel
        .invokeMethod("generatePlayerConfig");
    ;
  }

  ///回调分发
  void _onEvent(dynamic event) {
    String method = event[EventChanneldef.TYPE_KEY];
    String playerId = event['playerId'] ?? '';
    FlutterAliplayer player =
        FlutterAliPlayerFactory.instanceMap[playerId] ?? this;
    switch (method) {
      case "onPrepared":
        if (player.onPrepared != null) {
          player.onPrepared!(playerId);
        }
        break;
      case "onRenderingStart":
        if (player.onRenderingStart != null) {
          player.onRenderingStart!(playerId);
        }
        break;
      case "onVideoSizeChanged":
        if (player.onVideoSizeChanged != null) {
          int width = event['width'];
          int height = event['height'];
          int? rotation = event['rotation'];
          player.onVideoSizeChanged!(width, height, rotation, playerId);
        }
        break;
      case "onSnapShot":
        if (player.onSnapShot != null) {
          String snapShotPath = event['snapShotPath'];
          player.onSnapShot!(snapShotPath, playerId);
        }
        break;
      case "onChangedSuccess":
        break;
      case "onChangedFail":
        break;
      case "onSeekComplete":
        if (player.onSeekComplete != null) {
          player.onSeekComplete!(playerId);
        }
        break;
      case "onSeiData":
        if (player.onSeiData != null) {
          int type = event['type'];
          Uint8List data = event['data'];
          Uint8List uuid = event['uuid'];
          player.onSeiData!(type, uuid, data, playerId);
        }
        break;
      case "onLoadingBegin":
        if (player.onLoadingBegin != null) {
          player.onLoadingBegin!(playerId);
        }
        break;
      case "onLoadingProgress":
        int percent = event['percent'];
        double? netSpeed = event['netSpeed'];
        if (player.onLoadingProgress != null) {
          player.onLoadingProgress!(percent, netSpeed, playerId);
        }
        break;
      case "setPlaying":
        bool playing = event['playing'];
        if (player.onPipStatusChanged != null) {
          player.onPipStatusChanged!(playing, playerId);
        }
        break;
      case "WillStartPip":
        bool playing = event['pipStatus'];
        if (player.onWillStartPip != null) {
          player.onWillStartPip!(playing, playerId);
        }
        break;
      case "WillStopPip":
        bool playing = event['pipStatus'];
        if (player.onWillStopPip != null) {
          player.onWillStopPip!(playing, playerId);
        }
        break;
      case "onLoadingEnd":
        if (player.onLoadingEnd != null) {
          player.onLoadingEnd!(playerId);
        }
        break;
      case "onStateChanged":
        if (player.onStateChanged != null) {
          int newState = event['newState'];
          player.onStateChanged!(newState, playerId);
        }
        break;
      case "onInfo":
        if (player.onInfo != null) {
          int? infoCode = event['infoCode'];
          int? extraValue = event['extraValue'];
          String? extraMsg = event['extraMsg'];
          player.onInfo!(infoCode, extraValue, extraMsg, playerId);
        }
        break;
      case "onError":
        if (player.onError != null) {
          int errorCode = event['errorCode'];
          String? errorExtra = event['errorExtra'];
          String? errorMsg = event['errorMsg'];
          player.onError!(errorCode, errorExtra, errorMsg, playerId);
        }
        break;
      case "onCompletion":
        if (player.onCompletion != null) {
          player.onCompletion!(playerId);
        }
        break;
      case "onTrackReady":
        if (player.onTrackReady != null) {
          player.onTrackReady!(playerId);
        }
        break;
      case "onVideoRendered":
        if (player.onVideoRendered != null) {
          int timeMs = event['timeMs'];
          int pts = event['pts'];
          player.onVideoRendered!(timeMs, pts, playerId);
        }
        break;
      case "onTrackChanged":
        if (player.onTrackChanged != null) {
          dynamic info = event['info'];
          player.onTrackChanged!(info, playerId);
        }
        break;
      case "thumbnail_onPrepared_Success":
        if (player.onThumbnailPreparedSuccess != null) {
          player.onThumbnailPreparedSuccess!(playerId);
        }
        break;
      case "thumbnail_onPrepared_Fail":
        if (player.onThumbnailPreparedFail != null) {
          player.onThumbnailPreparedFail!(playerId);
        }
        break;
      case "onThumbnailGetSuccess":
        dynamic bitmap = event['thumbnailbitmap'];
        dynamic range = event['thumbnailRange'];
        if (player.onThumbnailGetSuccess != null) {
          if (Platform.isIOS) {
            range = Int64List.fromList(range.cast<int>());
          }
          player.onThumbnailGetSuccess!(bitmap, range, playerId);
        }
        break;
      case "onThumbnailGetFail":
        if (player.onThumbnailGetFail != null) {
          player.onThumbnailGetFail!(playerId);
        }
        break;
      case "onSubtitleExtAdded":
        if (player.onSubtitleExtAdded != null) {
          int trackIndex = event['trackIndex'];
          String url = event['url'];
          player.onSubtitleExtAdded!(trackIndex, url, playerId);
        }
        break;
      case "onSubtitleShow":
        if (player.onSubtitleShow != null) {
          int trackIndex = event['trackIndex'];
          int subtitleID = event['subtitleID'];
          String subtitle = event['subtitle'];
          player.onSubtitleShow!(trackIndex, subtitleID, subtitle, playerId);
        }
        break;
      case "onSubtitleHide":
        if (player.onSubtitleHide != null) {
          int trackIndex = event['trackIndex'];
          int subtitleID = event['subtitleID'];
          player.onSubtitleHide!(trackIndex, subtitleID, playerId);
        }
        break;
      case "onSubtitleHeader":
        if (player.onSubtitleHeader != null) {
          int trackIndex = event['trackIndex'];
          String header = event['header'];
          player.onSubtitleHeader!(trackIndex, header, playerId);
        }
        break;
      case "onUpdater":
        if (player.onTimeShiftUpdater != null) {
          var currentTime = event['currentTime'];
          var shiftStartTime = event['shiftStartTime'];
          var shiftEndTime = event['shiftEndTime'];
          player.onTimeShiftUpdater!(
              currentTime, shiftStartTime, shiftEndTime, playerId);
        }
        break;
      case "onSeekLiveCompletion":
        if (player.onSeekLiveCompletion != null) {
          var playTime = event['playTime'];
          player.onSeekLiveCompletion!(playTime, playerId);
        }
        break;
      case "onEventReportParams":
        if (player.onEventReportParams != null) {
          var params = event['params'];
          player.onEventReportParams!(params, playerId);
        }
    }
  }

  void _onError(dynamic error) {}
}

typedef void AliPlayerViewCreatedCallback(int viewId);

class AliPlayerView extends StatefulWidget {
  final AliPlayerViewCreatedCallback? onCreated;
  final x;
  final y;
  final width;
  final height;
  AliPlayerViewTypeForAndroid aliPlayerViewType;

  AliPlayerView({
    Key? key,
    @required required this.onCreated,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
    this.aliPlayerViewType = AliPlayerViewTypeForAndroid.surfaceview,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<AliPlayerView> {
  @override
  Widget build(BuildContext context) {
    return nativeView();
  }

  nativeView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'flutter_aliplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "viewType": widget.aliPlayerViewType.name,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: 'plugins.flutter_aliplayer',
        // viewType: 'flutter_aliplayer_render_view',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> _onPlatformViewCreated(id) async {
    if (widget.onCreated != null) {
      widget.onCreated!(id);
    }
  }
}
