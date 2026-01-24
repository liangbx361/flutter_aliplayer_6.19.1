import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_aliplayer_factory.dart';
import 'flutter_avpdef.dart';

export 'flutter_avpdef.dart';

typedef OnPrepared = void Function(String playerId);
typedef OnRenderingStart = void Function(String playerId);
typedef OnVideoSizeChanged = void Function(
    int width, int height, int? rotation, String playerId);
typedef OnSnapShot = void Function(String snapShotPath, String playerId);
typedef OnChangedSuccess = void Function(String playerId);
typedef OnChangedFail = void Function(String playerId);
typedef OnSeekComplete = void Function(String playerId);
typedef OnSeiData = void Function(
    int type, Uint8List uuid, Uint8List data, String playerId);
typedef OnLoadingBegin = void Function(String playerId);
typedef OnLoadingProgress = void Function(
    int percent, double? netSpeed, String playerId);
typedef OnLoadingEnd = void Function(String playerId);
typedef OnStateChanged = void Function(int newState, String playerId);
typedef OnInfo = void Function(
    int? infoCode, int? extraValue, String? extraMsg, String playerId);
typedef OnError = void Function(
    int errorCode, String? errorExtra, String? errorMsg, String playerId);
typedef OnCompletion = void Function(String playerId);
typedef OnTrackChanged = void Function(dynamic value, String playerId);
typedef OnThumbnailPreparedSuccess = void Function(String playerId);
typedef OnThumbnailPreparedFail = void Function(String playerId);
typedef OnThumbnailGetSuccess = void Function(
    Uint8List bitmap, String range, String playerId);
typedef OnThumbnailGetFail = void Function(String playerId);
typedef OnSubtitleShow = void Function(
    int trackIndex, int subtitleID, String subtitle, String playerId);
typedef OnSubtitleHide = void Function(
    int trackIndex, int subtitleID, String playerId);
typedef OnSubtitleHeader = void Function(
    int trackIndex, String header, String playerId);
typedef OnSubtitleExtAdded = void Function(
    int trackIndex, String url, String playerId);
typedef OnSeekLiveCompletion = void Function(int playTime, String playerId);
typedef OnTimeShiftUpdater = void Function(
    int currentTime, int shiftStartTime, int shiftEndTime, String playerId);
typedef OnEventReportParams = void Function(
    Map<dynamic, dynamic> params, String playerId);
typedef OnPipStatusChanged = void Function(bool isPip, String playerId);
typedef OnWillStartPip = void Function(bool isPip, String playerId);
typedef OnWillStopPip = void Function(bool isPip, String playerId);
typedef OnTrackReady = void Function(String playerId);

class FlutterAliplayer {
  String playerId = "";
  OnPrepared? onPrepared;
  OnRenderingStart? onRenderingStart;
  OnVideoSizeChanged? onVideoSizeChanged;
  OnSnapShot? onSnapShot;
  OnChangedSuccess? onChangedSuccess;
  OnChangedFail? onChangedFail;
  OnSeekComplete? onSeekComplete;
  OnSeiData? onSeiData;
  OnLoadingBegin? onLoadingBegin;
  OnLoadingProgress? onLoadingProgress;
  OnLoadingEnd? onLoadingEnd;
  OnStateChanged? onStateChanged;
  OnInfo? onInfo;
  OnError? onError;
  OnCompletion? onCompletion;
  OnTrackChanged? onTrackChanged;
  OnThumbnailPreparedSuccess? onThumbnailPreparedSuccess;
  OnThumbnailPreparedFail? onThumbnailPreparedFail;
  OnThumbnailGetSuccess? onThumbnailGetSuccess;
  OnThumbnailGetFail? onThumbnailGetFail;
  OnSubtitleShow? onSubtitleShow;
  OnSubtitleHide? onSubtitleHide;
  OnSubtitleHeader? onSubtitleHeader;
  OnSubtitleExtAdded? onSubtitleExtAdded;
  OnSeekLiveCompletion? onSeekLiveCompletion;
  OnTimeShiftUpdater? onTimeShiftUpdater;
  OnEventReportParams? onEventReportParams;
  OnPipStatusChanged? onPipStatusChanged;
  OnWillStartPip? onWillStartPip;
  OnWillStopPip? onWillStopPip;
  OnTrackReady? onTrackReady;

  // Internal State
  int mState = FlutterAvpdef.idle;
  int mDuration = 100000; // 100 seconds mock
  int mCurrentPosition = 0;
  bool mIsAutoPlay = false;
  bool mIsLoop = false;
  bool mIsMuted = false;
  double mVolume = 1.0;
  double mRate = 1.0;
  int mRotateMode = 0;
  int mScalingMode = 0;
  int mMirrorMode = 0;
  int mAlphaRenderMode = 0;
  int mVideoWidth = 1920;
  int mVideoHeight = 1080;
  int mVideoRotation = 0;
  Timer? mPositionTimer;

  FlutterAliplayer.init(id) {
    this.playerId = id.toString();
    FlutterAliPlayerFactory.instanceMap[this.playerId] = this;
  }

  void fireEvent(String type, Map<String, dynamic> data) {
    Map<String, dynamic> event = {
      EventChanneldef.TYPE_KEY: type,
      'playerId': playerId,
      ...data
    };
    handleEvent(event);
  }

  // Listener Setters
  void setOnPrepared(OnPrepared onPrepared) => this.onPrepared = onPrepared;
  void setOnRenderingStart(OnRenderingStart onRenderingStart) =>
      this.onRenderingStart = onRenderingStart;
  void setOnVideoSizeChanged(OnVideoSizeChanged onVideoSizeChanged) =>
      this.onVideoSizeChanged = onVideoSizeChanged;
  void setOnSnapShot(OnSnapShot onSnapShot) => this.onSnapShot = onSnapShot;
  void setOnChangedSuccess(OnChangedSuccess onChangedSuccess) =>
      this.onChangedSuccess = onChangedSuccess;
  void setOnChangedFail(OnChangedFail onChangedFail) =>
      this.onChangedFail = onChangedFail;
  void setOnSeekComplete(OnSeekComplete onSeekComplete) =>
      this.onSeekComplete = onSeekComplete;
  void setOnSeiData(OnSeiData onSeiData) => this.onSeiData = onSeiData;
  void setOnLoadingBegin(OnLoadingBegin onLoadingBegin) =>
      this.onLoadingBegin = onLoadingBegin;
  void setOnLoadingProgress(OnLoadingProgress onLoadingProgress) =>
      this.onLoadingProgress = onLoadingProgress;
  void setOnLoadingEnd(OnLoadingEnd onLoadingEnd) =>
      this.onLoadingEnd = onLoadingEnd;
  void setOnStateChanged(OnStateChanged onStateChanged) =>
      this.onStateChanged = onStateChanged;
  void setOnInfo(OnInfo onInfo) => this.onInfo = onInfo;
  void setOnError(OnError onError) => this.onError = onError;
  void setOnCompletion(OnCompletion onCompletion) =>
      this.onCompletion = onCompletion;
  void setOnTrackChanged(OnTrackChanged onTrackChanged) =>
      this.onTrackChanged = onTrackChanged;
  void setOnTrackReady(OnTrackReady onTrackReady) =>
      this.onTrackReady = onTrackReady;

  void setOnLoadingStatusListener(
      {OnLoadingBegin? loadingBegin,
      OnLoadingProgress? loadingProgress,
      OnLoadingEnd? loadingEnd}) {
    this.onLoadingBegin = loadingBegin;
    this.onLoadingProgress = loadingProgress;
    this.onLoadingEnd = loadingEnd;
  }

  void setPipController(
      {OnPipStatusChanged? pipStatusChanged,
      OnWillStartPip? willStartPip,
      OnWillStopPip? willStopPip}) {
    this.onPipStatusChanged = pipStatusChanged;
    this.onWillStartPip = willStartPip;
    this.onWillStopPip = willStopPip;
  }

  void setOnThumbnailPreparedListener(
      {required OnThumbnailPreparedSuccess preparedSuccess,
      required OnThumbnailPreparedFail preparedFail}) {
    this.onThumbnailPreparedSuccess = preparedSuccess;
    this.onThumbnailPreparedFail = preparedFail;
  }

  void setOnThumbnailGetListener(
      {required OnThumbnailGetSuccess onThumbnailGetSuccess,
      required OnThumbnailGetFail onThumbnailGetFail}) {
    this.onThumbnailGetSuccess = onThumbnailGetSuccess;
    this.onThumbnailGetFail = onThumbnailGetFail;
  }

  void setOnSubtitleShow(OnSubtitleShow onSubtitleShow) =>
      this.onSubtitleShow = onSubtitleShow;
  void setOnSubtitleHide(OnSubtitleHide onSubtitleHide) =>
      this.onSubtitleHide = onSubtitleHide;
  void setOnSubtitleHeader(OnSubtitleHeader onSubtitleHeader) =>
      this.onSubtitleHeader = onSubtitleHeader;
  void setOnSubtitleExtAdded(OnSubtitleExtAdded onSubtitleExtAdded) =>
      this.onSubtitleExtAdded = onSubtitleExtAdded;
  void setOnSeekLiveCompletion(OnSeekLiveCompletion seekLiveCompletion) =>
      this.onSeekLiveCompletion = seekLiveCompletion;
  void setOnTimeShiftUpdater(OnTimeShiftUpdater timeShiftUpdater) =>
      this.onTimeShiftUpdater = timeShiftUpdater;
  void setOnEventReportParams(OnEventReportParams eventReportParams) =>
      this.onEventReportParams = eventReportParams;

  wrapWithPlayerId({arg = ''}) {
    return {"arg": arg, "playerId": this.playerId.toString()};
  }

  // Player Methods
  Future<void> create() async {
    mState = FlutterAvpdef.initalized;
    fireEvent("onStateChanged", {"newState": mState});
  }

  Future<void> setPlayerView(int viewId) async {}
  Future<void> setUrl(String url) async {}

  Future<void> prepare() async {
    mState = FlutterAvpdef.prepared;
    fireEvent("onStateChanged", {"newState": mState});
    fireEvent("onPrepared", {});
    fireEvent("onTrackReady", {});
    if (mIsAutoPlay) play();
  }

  Future<void> play() async {
    if (mState == FlutterAvpdef.prepared || mState == FlutterAvpdef.paused) {
      mState = FlutterAvpdef.started;
      fireEvent("onStateChanged", {"newState": mState});
      fireEvent("onRenderingStart", {});
      startPositionTimer();
    }
  }

  Future<void> pause() async {
    if (mState == FlutterAvpdef.started) {
      mState = FlutterAvpdef.paused;
      fireEvent("onStateChanged", {"newState": mState});
      stopPositionTimer();
    }
  }

  Future<void> stop() async {
    mState = FlutterAvpdef.stopped;
    fireEvent("onStateChanged", {"newState": mState});
    stopPositionTimer();
  }

  Future<void> destroy() async {
    stopPositionTimer();
    FlutterAliPlayerFactory.instanceMap.remove(playerId);
  }

  Future<void> releaseAsync() async => destroy();

  Future<void> seekTo(int position, int seekMode) async {
    mCurrentPosition = position;
    fireEvent("onInfo", {
      "infoCode": FlutterAvpdef.CURRENTPOSITION,
      "extraValue": mCurrentPosition,
      "extraMsg": ""
    });
  }

  Future<void> setStartTime(int time, int seekMode) async {
    mCurrentPosition = time;
  }

  Future<void> setOption(int opt1, Object opt2) async {}
  Future<void> setMaxAccurateSeekDelta(int delta) async {}
  Future<dynamic> isLoop() async => mIsLoop;
  Future<void> setLoop(bool isloop) async => mIsLoop = isloop;
  Future<dynamic> isAutoPlay() async => mIsAutoPlay;
  Future<void> setAutoPlay(bool isAutoPlay) async => mIsAutoPlay = isAutoPlay;
  Future<void> setFastStart(bool fastStart) async {}
  Future<dynamic> isMuted() async => mIsMuted;
  Future<void> setMuted(bool isMuted) async => mIsMuted = isMuted;
  Future<dynamic> enableHardwareDecoder() async => false;
  Future<void> setEnableHardwareDecoder(bool isHardWare) async {}
  Future<void> setRenderFrameCallbackConfig(
      bool mAudioData, bool mVideoData) async {}

  Future<void> setVidSts(
      {vid,
      region,
      accessKeyId,
      accessKeySecret,
      securityToken,
      playConfig,
      definitionList,
      quality = "",
      forceQuality = false,
      playerId}) async {}
  Future<void> setVidAuth(
      {vid,
      region,
      playAuth,
      playConfig,
      definitionList,
      quality = "",
      forceQuality = false,
      playerId}) async {}
  Future<void> setVidMps(Map<String, dynamic> mpsInfo) async {}
  Future<void> setLiveSts(
      {url,
      accessKeyId,
      accessKeySecret,
      securityToken,
      region,
      domain,
      app,
      stream,
      encryptionType,
      definitionList,
      playerId}) async {}
  Future<dynamic> updateLiveStsInfo(
          String accId, String accKey, String token, String region) async =>
      0;

  Future<dynamic> getRotateMode() async => mRotateMode;
  Future<void> setRotateMode(int mode) async => mRotateMode = mode;
  Future<dynamic> getScalingMode() async => mScalingMode;
  Future<void> setScalingMode(int mode) async => mScalingMode = mode;
  Future<void> setOutputAudioChannel(int chanel) async {}
  Future<dynamic> getMirrorMode() async => mMirrorMode;
  Future<void> setMirrorMode(int mode) async => mMirrorMode = mode;
  Future<dynamic> getAlphaRenderMode() async => mAlphaRenderMode;
  Future<void> setAlphaRenderMode(int mode) async => mAlphaRenderMode = mode;
  Future<dynamic> getRate() async => mRate;
  Future<void> setRate(double mode) async => mRate = mode;
  Future<void> setVideoBackgroundColor(var color) async {}
  Future<dynamic> getVideoWidth() async => mVideoWidth;
  Future<dynamic> getVideoHeight() async => mVideoHeight;
  Future<dynamic> getVideoRotation() async => mVideoRotation;
  Future<void> setVolume(double volume) async => mVolume = volume;
  Future<dynamic> getVolume() async => mVolume;
  Future<dynamic> getDuration() async => mDuration;
  Future<dynamic> getCurrentPosition() async => mCurrentPosition;
  Future<dynamic> getCurrentUtcTime() async =>
      DateTime.now().millisecondsSinceEpoch;
  Future<dynamic> getLocalCacheLoadedSize() async => 0;
  Future<dynamic> getCurrentDownloadSpeed() async => 0;
  Future<dynamic> getBufferedPosition() async => mDuration ~/ 2;
  Future<dynamic> getConfig() async => {};
  Future<AVPConfig> getPlayConfig() async => AVPConfig();
  Future<void> setConfig(Map map) async {}
  Future<void> setPlayConfig(AVPConfig config) async {}
  Future<void> enableDowngrade(String source, AVPConfig config) async {}
  Future<dynamic> getCacheConfig() async => {};
  Future<void> setCacheConfig(Map map) async {}
  Future<void> setFilterConfig(String configJson) async {}
  Future<void> updateFilterConfig(String target, Map options) async {}
  Future<void> setFilterInvalid(String target, String invalid) async {}
  Future<dynamic> getCacheFilePath(String url) async => "";
  Future<dynamic> getCacheFilePathWithVid(
          String vid, String format, String definition) async =>
      "";
  Future<dynamic> getCacheFilePathWithVidAtPreviewTime(String vid,
          String format, String definition, String previewTime) async =>
      "";
  Future<dynamic> getMediaInfo() async => {"duration": mDuration};
  Future<dynamic> getSubMediaInfo() async => {};
  Future<dynamic> getCurrentTrack(int trackIdx) async => {};
  Future<dynamic> createThumbnailHelper(String thumbnail) async {}
  Future<dynamic> setConvertURLCallback(String newUrl) async {}
  Future<dynamic> requestBitmapAtPosition(int position) async {}
  Future<dynamic> setTraceID(String traceID) async {}
  Future<void> addExtSubtitle(String url) async {}
  Future<void> selectExtSubtitle(int trackIndex, bool enable) async {}
  Future<void> setDefaultBandWidth(int parse) async {}
  Future<void> selectTrack(int trackIdx, {int accurate = -1}) async {}
  Future<void> setPrivateService(Int8List data) async {}
  Future<void> setPreferPlayerName(String playerName) async {}
  Future<void> setPictureInPictureShowMode(int showMode) async {}
  Future<dynamic> getPlayerName() async => "MockPlayer";
  Future<void> sendCustomEvent(String args) async {}
  Future<void> setUserData(String userData) async {}
  Future<dynamic> getUserData() async => "";
  Future<void> setStreamDelayTime(int trackIdx, int time) async {}
  Future<void> reload() async {}
  Future<dynamic> getOption(AVPOption key) async => "";
  Future<dynamic> getPropertyString(AVPPropertyKey key) async => "";
  Future<dynamic> setEventReportParamsDelegate(int argt) async => 0;
  Future<dynamic> setPictureInPictureEnableForIOS(bool enable) async => 0;
  Future<void> clearScreen() async {}
  Future<void> clearScreenSync() async {}
  Future<dynamic> snapshot(String path) async {
    if (onSnapShot != null) onSnapShot!(path, playerId);
    return 0;
  }

  // Static Methods
  static Future<dynamic> getSDKVersion() async => "6.19.1-mock";
  static Future<dynamic> getDeviceUUID() async => "mock-uuid";
  static Future<bool> isFeatureSupport(SupportFeatureType type) async => true;
  static Future<void> setAudioSessionTypeForIOS(
      AliPlayerAudioSesstionType type) async {}
  static Future<void> enableConsoleLog(bool enable) async {}
  static Future<void> setLogLevel(int level) async {}
  static Future<void> setAdaptiveDecoderGetBackupURLCallback() async {}
  static Future<dynamic> getLogLevel() async => 0;
  static Future<void> setUseHttp2(bool use) async {}
  static Future<void> enableHttpDns(bool enable) async {}
  static Future<void> setDNSResolve(String host, String ip) async {}
  static Future<void> setIpResolveType(AVPIpResolveType type) async {}
  static Future<void> setFairPlayCertIDForIOS(String certID) async {}
  static Future<void> enableHWAduioTempo(bool enable) async {}
  static Future<void> forceAudioRendingFormat(
      String force, String fmt, String channels, String sample_rate) async {}
  static Future<void> netWorkReConnect() async {}
  static Future<void> enableLocalCache(bool enable, String maxBufferMemoryKB,
      String localCacheDir, DocTypeForIOS docTypeForIOS) async {}
  static Future<void> setCacheFileClearConfig(
      String expireMin, String maxCapacityMB, String freeStorageMB) async {}
  static Future<void> enableNetworkBalance(bool enable) async {}
  static Future<void> clearCaches() async {}
  static Future<dynamic> createDeviceInfo() async => {};
  static Future<void> addBlackDevice(String type, String model) async {}
  static Future<void> createVidPlayerConfigGenerator() async {}
  static Future<void> setPreviewTime(int previewTime) async {}
  static Future<void> setHlsUriToken(String mtsHlsUriToken) async {}
  static Future<void> addVidPlayerConfigByStringValue(
      String key, String value) async {}
  static Future<void> addVidPlayerConfigByIntValue(
      String key, int value) async {}
  static Future<void> setEncryptType(EncryptType type) async {}
  static Future<String> generatePlayerConfig() async => "";

  // Internal Logic
  void startPositionTimer() {
    mPositionTimer?.cancel();
    mPositionTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mState == FlutterAvpdef.started) {
        mCurrentPosition += 500;
        if (mCurrentPosition >= mDuration) {
          if (mIsLoop) {
            mCurrentPosition = 0;
            fireEvent("onInfo", {
              "infoCode": FlutterAvpdef.LOOPINGSTART,
              "extraValue": 0,
              "extraMsg": ""
            });
          } else {
            mCurrentPosition = mDuration;
            mState = FlutterAvpdef.completion;
            fireEvent("onStateChanged", {"newState": mState});
            fireEvent("onCompletion", {});
            stopPositionTimer();
          }
        }
        fireEvent("onInfo", {
          "infoCode": FlutterAvpdef.CURRENTPOSITION,
          "extraValue": mCurrentPosition,
          "extraMsg": ""
        });
      }
    });
  }

  void stopPositionTimer() {
    mPositionTimer?.cancel();
    mPositionTimer = null;
  }

  void handleEvent(dynamic event) {
    String method = event[EventChanneldef.TYPE_KEY];
    String playerId = event['playerId'] ?? '';
    FlutterAliplayer player =
        FlutterAliPlayerFactory.instanceMap[playerId] ?? this;

    switch (method) {
      case "onPrepared":
        player.onPrepared?.call(playerId);
        break;
      case "onRenderingStart":
        player.onRenderingStart?.call(playerId);
        break;
      case "onVideoSizeChanged":
        player.onVideoSizeChanged?.call(
            event['width'], event['height'], event['rotation'], playerId);
        break;
      case "onSnapShot":
        player.onSnapShot?.call(event['snapShotPath'], playerId);
        break;
      case "onSeekComplete":
        player.onSeekComplete?.call(playerId);
        break;
      case "onLoadingBegin":
        player.onLoadingBegin?.call(playerId);
        break;
      case "onLoadingProgress":
        player.onLoadingProgress
            ?.call(event['percent'], event['netSpeed'], playerId);
        break;
      case "onLoadingEnd":
        player.onLoadingEnd?.call(playerId);
        break;
      case "onStateChanged":
        player.onStateChanged?.call(event['newState'], playerId);
        break;
      case "onInfo":
        player.onInfo?.call(event['infoCode'], event['extraValue'],
            event['extraMsg'], playerId);
        break;
      case "onError":
        player.onError?.call(event['errorCode'], event['errorExtra'],
            event['errorMsg'], playerId);
        break;
      case "onCompletion":
        player.onCompletion?.call(playerId);
        break;
      case "onTrackChanged":
        player.onTrackChanged?.call(event['value'], playerId);
        break;
      case "onTrackReady":
        player.onTrackReady?.call(playerId);
        break;
    }
  }
}

typedef void AliPlayerViewCreatedCallback(int viewId);

class AliPlayerView extends StatefulWidget {
  final AliPlayerViewCreatedCallback? onCreated;
  final double x;
  final double y;
  final double width;
  final double height;
  final AliPlayerViewTypeForAndroid aliPlayerViewType;

  AliPlayerView({
    Key? key,
    required this.onCreated,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.aliPlayerViewType = AliPlayerViewTypeForAndroid.surfaceview,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<AliPlayerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onCreated != null) {
        widget.onCreated!(0); // Mock view ID
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text("AliPlayer Mock View", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
