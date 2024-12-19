class FlutterAvpdef {
  /**@brief 不保持比例平铺*/

  /// **@brief Auto stretch to fit.*/
  static const int AVP_SCALINGMODE_SCALETOFILL = 0;

  /**@brief 保持比例，黑边*/

  /// **@brief Keep aspect ratio and add black borders.*/
  static const int AVP_SCALINGMODE_SCALEASPECTFIT = 1;

  /**@brief 保持比例填充，需裁剪*/

  /// **@brief Keep aspect ratio and crop.*/
  static const int AVP_SCALINGMODE_SCALEASPECTFILL = 2;

  /**@brief 旋转模式*/

  /// **@brief Rotate mode*/
  static const int AVP_ROTATE_0 = 0;
  static const int AVP_ROTATE_90 = 90;
  static const int AVP_ROTATE_180 = 180;
  static const int AVP_ROTATE_270 = 270;

  /**@brief 镜像模式*/

  /// **@brief Mirroring mode*/
  static const int AVP_MIRRORMODE_NONE = 0;
  static const int AVP_MIRRORMODE_HORIZONTAL = 1;
  static const int AVP_MIRRORMODE_VERTICAL = 2;

  ///AliPlayer的特定功能选项
  static const int SET_MEDIA_TYPE = 0;
  static const int ALLOW_DECODE_BACKGROUND = 1;
  static const int ALLOW_PRE_RENDER = 2;

  ///license配置
  static const int ENV_GLOBAL_DEFAULT = 0;
  static const int ENV_CN = 1;
  static const int ENV_SEA = 2;

  // 画中画显示模式
  static const int AVP_SHOW_MODE_DEFAULT = 0;
  static const int AVP_SHOW_MODE_HIDE_FAST_FORWARD_REWIND = 1;

  /// Log 日志级别
  static const int AF_LOG_LEVEL_NONE = 0;
  static const int AF_LOG_LEVEL_FATAL = 8;
  static const int AF_LOG_LEVEL_ERROR = 16;
  static const int AF_LOG_LEVEL_WARNING = 24;
  static const int AF_LOG_LEVEL_INFO = 32;
  static const int AF_LOG_LEVEL_DEBUG = 48;
  static const int AF_LOG_LEVEL_TRACE = 56;

  /// AlphaRenderMode
  static const int RENDER_MODE_ALPHA_NONE = 0;
  static const int RENDER_MODE_ALPHA_AT_RIGHT = 1;
  static const int RENDER_MODE_ALPHA_AT_LEFT = 2;
  static const int RENDER_MODE_ALPHA_AT_TOP = 3;
  static const int RENDER_MODE_ALPHA_AT_BOTTOM = 4;

  ///infoCode
  static const int UNKNOWN = -1;
  static const int LOOPINGSTART = 0;
  static const int BUFFEREDPOSITION = 1;
  static const int CURRENTPOSITION = 2;
  static const int AUTOPLAYSTART = 3;
  static const int SWITCHTOSOFTWAREVIDEODECODER = 100;
  static const int AUDIOCODECNOTSUPPORT = 101;
  static const int AUDIODECODERDEVICEERROR = 102;
  static const int VIDEOCODECNOTSUPPORT = 103;
  static const int VIDEODECODERDEVICEERROR = 104;
  static const int VIDEORENDERINITERROR = 105;
  static const int DEMUXERTRACEID = 106;
  static const int NETWORKRETRY = 108;
  static const int CACHESUCCESS = 109;
  static const int CACHEERROR = 110;
  static const int LOWMEMORY = 111;
  static const int NETWORKRETRYSUCCESS = 113;
  static const int SUBTITLESELECTERROR = 114;
  static const int DIRECTCOMPONENTMSG = 116;
  static const int RTSSERVERMAYBEDISCONNECT = 805371905;
  static const int RTSSERVERRECOVER = 805371906;

  ///点播服务器返回的码率清晰度类型
  static const String FD = "FD";
  static const String LD = "LD";
  static const String SD = "SD";
  static const String HD = "HD";
  static const String OD = "OD";
  static const String K2 = "2K";
  static const String K4 = "4K";
  static const String SQ = "SQ";
  static const String HQ = "HQ";
  static const String AUTO = "AUTO";

  ///播放器状态
  static const int unknow = -1;
  static const int idle = 0;
  static const int initalized = 1;
  static const int prepared = 2;
  static const int started = 3;
  static const int paused = 4;
  static const int stopped = 5;
  static const int completion = 6;
  static const int error = 7;

  ///精准seek
  static const int ACCURATE = 1;
  static const int INACCURATE = 16;

  ///下载方式
  static const String DOWNLOADTYPE_STS = "download_sts";
  static const String DOWNLOADTYPE_AUTH = "download_auth";

  ///黑名单
  static const String BLACK_DEVICES_H264 = "HW_Decode_H264";
  static const String BLACK_DEVICES_HEVC = "HW_Decode_HEVC";

  static const int AVPTRACK_TYPE_VIDEO = 0;
  static const int AVPTRACK_TYPE_AUDIO = 1;
  static const int AVPTRACK_TYPE_SUBTITLE = 2;
  static const int AVPTRACK_TYPE_SAAS_VOD = 3;

  //  空转，闲时，静态
  static const int AVPStatus_AVPStatusIdle = 0;

  // /** @brief 初始化完成 */
  static const int AVPStatus_AVPStatusInitialzed = 1;

  // /** @brief 准备完成 */
  static const int AVPStatus_AVPStatusPrepared = 2;

  // /** @brief 正在播放 */
  static const int AVPStatus_AVPStatusStarted = 3;

  // /** @brief 播放暂停 */
  static const int AVPStatus_AVPStatusPaused = 4;

  // /** @brief 播放停止 */
  static const int AVPStatus_AVPStatusStopped = 5;

  // /** @brief 播放完成 */
  static const int AVPStatus_AVPStatusCompletion = 6;

  // /** @brief 播放错误
  static const int AVPStatus_AVPStatusError = 7;
}

class EventChanneldef {
  static const String TYPE_KEY = "method";

  static const String DOWNLOAD_PREPARED = "download_prepared";
  static const String DOWNLOAD_PROGRESS = "download_progress";
  static const String DOWNLOAD_PROCESS = "download_process";
  static const String DOWNLOAD_COMPLETION = "download_completion";
  static const String DOWNLOAD_ERROR = "download_error";
}

class PlayerType {
  static const int PlayerType_Single = 0;
  static const int PlayerType_List = 1;
  static const int PlayerType_LiveShift = 2;
}

class PixelNumber {
  static const int Resolution_360P = 172800;
  static const int Resolution_480P = 345600;
  static const int Resolution_540P = 518400;
  static const int Resolution_720P = 921600;
  static const int Resolution_1080P = 2073600;
  static const int Resolution_2K = 3686400;
  static const int Resolution_4K = 8847360;
  static const int Resolution_NoLimit = 2147483647;
}

class AVPMediaInfo {
  String? status;
  String? mediaType;
  List<AVPThumbnailInfo>? thumbnails = [];
  List<AVPTrackInfo>? tracks = [];
  String? title;
  int? duration;
  String? transcodeMode;
  String? coverURL;

  AVPMediaInfo(
      {this.status,
      this.mediaType,
      this.thumbnails,
      this.tracks,
      this.title,
      this.duration,
      this.transcodeMode,
      this.coverURL});

  AVPMediaInfo.fromJson(Map<dynamic, dynamic> json) {
    status = json['status'];
    mediaType = json['mediaType'];
    if (json['thumbnails'] != null) {
      // thumbnails = new List<AVPThumbnailInfo>();
      // thumbnails = List.empty();
      json['thumbnails'].forEach((v) {
        thumbnails!.add(new AVPThumbnailInfo.fromJson(v));
      });
    }
    if (json['tracks'] != null) {
      // tracks = new List<AVPTrackInfo>();
      json['tracks'].forEach((v) {
        tracks!.add(new AVPTrackInfo.fromJson(v));
      });
    }
    title = json['title'];
    duration = json['duration'];
    transcodeMode = json['transcodeMode'];
    coverURL = json['coverURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['mediaType'] = this.mediaType;
    if (this.thumbnails != null) {
      data['thumbnails'] = this.thumbnails!.map((v) => v.toJson()).toList();
    }
    if (this.tracks != null) {
      data['tracks'] = this.tracks!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['duration'] = this.duration;
    data['transcodeMode'] = this.transcodeMode;
    data['coverURL'] = this.coverURL;
    return data;
  }
}

class AVPTrackInfo {
  String? vodFormat;
  int? videoHeight;
  String? subtitleLanguage;
  int? videoWidth;
  int? trackBitrate;
  int? vodFileSize;
  int? trackIndex;
  String? trackDefinition;
  int? audioSampleFormat;
  String? audioLanguage;
  String? vodPlayUrl;
  int? trackType;
  int? audioSamplerate;
  int? audioChannels;

  AVPTrackInfo(
      {this.vodFormat,
      this.videoHeight,
      this.subtitleLanguage,
      this.videoWidth,
      this.trackBitrate,
      this.vodFileSize,
      this.trackIndex,
      this.trackDefinition,
      this.audioSampleFormat,
      this.audioLanguage,
      this.vodPlayUrl,
      this.trackType,
      this.audioSamplerate,
      this.audioChannels});

  AVPTrackInfo.fromJson(Map<dynamic, dynamic> json) {
    vodFormat = json['vodFormat'];
    videoHeight = json['videoHeight'];
    subtitleLanguage = json['subtitleLanguage'];
    videoWidth = json['videoWidth'];
    trackBitrate = json['trackBitrate'];
    vodFileSize = json['vodFileSize'];
    trackIndex = json['trackIndex'];
    trackDefinition = json['trackDefinition'];
    audioSampleFormat = json['audioSampleFormat'];
    audioLanguage = json['audioLanguage'];
    vodPlayUrl = json['vodPlayUrl'];
    trackType = json['trackType'];
    audioSamplerate = json['audioSamplerate'];
    audioChannels = json['audioChannels'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vodFormat'] = this.vodFormat;
    data['videoHeight'] = this.videoHeight;
    data['subtitleLanguage'] = this.subtitleLanguage;
    data['videoWidth'] = this.videoWidth;
    data['trackBitrate'] = this.trackBitrate;
    data['vodFileSize'] = this.vodFileSize;
    data['trackIndex'] = this.trackIndex;
    data['trackDefinition'] = this.trackDefinition;
    data['audioSampleFormat'] = this.audioSampleFormat;
    data['audioLanguage'] = this.audioLanguage;
    data['vodPlayUrl'] = this.vodPlayUrl;
    data['trackType'] = this.trackType;
    data['audioSamplerate'] = this.audioSamplerate;
    data['audioChannels'] = this.audioChannels;
    return data;
  }
}

class AVPThumbnailInfo {
  String? url;

  AVPThumbnailInfo.fromJson(Map<dynamic, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}

class AVPFilterInfo {
  String? target;
  List<String>? options;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['target'] = target;
    data['options'] = options;
    return data;
  }
}

enum AVPOption {
  // /** @brief 渲染的fps*/
  render_fps,
  // /** @brief 当前的网络下行码率*/
  download_bitrate,
  // /** @brief 当前播放的视频码率*/
  video_bitrate,
  // /** @brief 当前播放的音频码率*/
  audio_bitrate,
}

/// 获取信息播放器的key
enum AVPPropertyKey {
  // /** @brief Http的response信息*/
  // 返回的字符串是JSON数组，每个对象带response和type字段。type字段可以是url/video/audio/subtitle，根据流是否有相应Track返回。
  // 例如：[{"response":"response string","type":"url"},{"response":"","type":"video"}]

  response_info,

  // /** @brief 主URL的连接信息*/
  // 返回的字符串是JSON对象，带url/ip/eagleID/cdnVia/cdncip/cdnsip等字段（如果解析不到则不添加）
  // 例如：{"url":"http://xxx","openCost":23,"ip":"11.111.111.11","cdnVia":"xxx","cdncip":"22.222.222.22","cdnsip":"xxx"}
  connect_info,
}

/// encryptType
enum EncryptType {
  Unencrypted,
  AliyunVoDEncryption,
  HLSEncryption,
}

/// encryptionType
enum EncryptionType {
  none,
  alivodEncryption,
  fairPlay,
}

/// IP 解析类型
enum AVPIpResolveType {
  whatEver,
  v4,
  v6,
}

/// iOS 沙盒目录类型
enum DocTypeForIOS {
  // Documents
  documents,
  // Llibrary
  library,
  // Caches
  caches,
}

///Android 渲染 View 类型
enum AliPlayerViewTypeForAndroid {
  surfaceview,
  textureview,
}

/// AVPConfig设置
class AVPConfig {
  /// 清晰度切换至AUTO档位时，允许升路的清晰度视频对应的最大像素数量。
  /// 例如将值设置为1280 * 720 = 921600，那么最高升路到该对应清晰度，而不会升路到 1920 * 1080
  /// 不同清晰度对应值可以参考 PixelNumber
  int? mMaxAllowedAbrVideoPixelNumber;

  /// 直播最大延迟 默认5000毫秒，单位毫秒
  int? maxDelayTime;

  /// 卡顿后缓存数据的高水位，当播放器缓存数据大于此值时开始播放，单位毫秒
  int? highBufferDuration;

  /// 开始起播缓存区数据长度，默认500ms，单位毫秒
  int? startBufferDuration;

  /// 播放器最大的缓存数据长度，默认50秒，单位毫秒
  int? maxBufferDuration;

  /// 网络超时时间，默认15秒，单位毫秒
  int? networkTimeout;

  /// 网络重试次数，每次间隔networkTimeout，networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
  int? networkRetryCount;

  /// probe数据大小，默认-1,表示不设置
  int? maxProbeSize;

  /// 请求referer
  String? referer;

  /// user Agent
  String? userAgent;

  /// httpProxy代理
  String? httpProxy;

  /// 调用stop停止后是否显示最后一帧图像，YES代表清除显示，黑屏，默认为NO
  bool? clearShowWhenStop;

  /// 添加自定义header
  List? httpHeaders;

  /// 是否启用SEI
  bool? enableSEI;

  /// 是否开启本地缓存
  bool? enableLocalCache;

  /// set the video format for renderFrame callback
  int? pixelBufferOutputFormat;

  /// HLS直播时，起播分片位置。
  int? liveStartIndex;

  /// 禁用Audio.
  bool? disableAudio;

  /// 禁用Video
  bool? disableVideo;

  /// 进度跟新的频率。包括当前位置和缓冲位置。
  int? positionTimerIntervalMs;

  /// 设置播放器后向buffer的最大值.
  int? mMAXBackwardDuration;

  /// 优先保证音频播放；在网络带宽不足的情况下，优先保障音频的播放，目前只在dash直播流中有效（视频已经切换到了最低码率）
  bool? preferAudio;

  /// 播放器实例是否可以使用http dns进行解析，-1 表示跟随全局设置，0 disable
  int? enableHttpDns;

  /// 使用http3进行请求，支持标准：RFC 9114（HTTP3）和RFC 9000（QUIC v1），默认值关。如果http3请求失败，自动降级至普通http，默认关闭
  bool? enableHttp3;

  /// 用于纯音频或纯视频的RTMP/FLV直播流起播优化策略，当流的header声明只有音频或只有视频时，且实际流的内容跟header声明一致时，此选项打开可以达到快速起播的效果。默认关闭
  bool? enableStrictFlvHeader;

  /// 针对打开了点播URL鉴权的媒体资源（HLS协议），开启本地缓存后，可选择不同的鉴权模式：非严格鉴权(false)：鉴权也缓存，若上一次只缓存了部分媒体，下次播放至非缓存部分时，播放器会用缓存的鉴权发起请求，如果URL鉴权设置的有效很短的话，会导致播放异常。严格鉴权(true)：鉴权不缓存，每次起播都进行鉴权，无网络下会导致起播失败。默认值：false。
  bool? enableStrictAuthMode;

  /// 允许当前播放器实例进行投屏,你需要集成投屏SDK来完成投屏功能,默认值关
  bool? enableProjection;

  /// AVPConfig类型的playConfig转为Map类型
  Map convertToMap() {
    Map map = {};
    if (this.mMaxAllowedAbrVideoPixelNumber != null) {
      map.addAll({
        "mMaxAllowedAbrVideoPixelNumber": this.mMaxAllowedAbrVideoPixelNumber
      });
    }
    if (this.maxDelayTime != null) {
      map.addAll({"maxDelayTime": this.maxDelayTime});
    }
    if (this.highBufferDuration != null) {
      map.addAll({"highBufferDuration": this.highBufferDuration});
    }
    if (this.startBufferDuration != null) {
      map.addAll({"startBufferDuration": this.startBufferDuration});
    }
    if (this.maxBufferDuration != null) {
      map.addAll({"maxBufferDuration": this.maxBufferDuration});
    }
    if (this.networkTimeout != null) {
      map.addAll({"networkTimeout": this.networkTimeout});
    }
    if (this.networkRetryCount != null) {
      map.addAll({"networkRetryCount": this.networkRetryCount});
    }
    if (this.referer != null) {
      map.addAll({"referer": this.referer});
    }
    if (this.userAgent != null) {
      map.addAll({"userAgent": this.userAgent});
    }
    if (this.httpProxy != null) {
      map.addAll({"httpProxy": this.httpProxy});
    }
    if (this.clearShowWhenStop != null) {
      map.addAll({"clearShowWhenStop": this.clearShowWhenStop});
    }
    if (this.httpHeaders != null) {
      map.addAll({"httpHeaders": this.httpHeaders});
    }
    if (this.enableSEI != null) {
      map.addAll({"enableSEI": this.enableSEI});
    }
    if (this.enableLocalCache != null) {
      map.addAll({"enableLocalCache": this.enableLocalCache});
    }
    if (this.pixelBufferOutputFormat != null) {
      map.addAll({"pixelBufferOutputFormat": this.pixelBufferOutputFormat});
    }
    if (this.liveStartIndex != null) {
      map.addAll({"liveStartIndex": this.liveStartIndex});
    }
    if (this.disableAudio != null) {
      map.addAll({"disableAudio": this.disableAudio});
    }
    if (this.disableVideo != null) {
      map.addAll({"disableVideo": this.disableVideo});
    }
    if (this.positionTimerIntervalMs != null) {
      map.addAll({"positionTimerIntervalMs": this.positionTimerIntervalMs});
    }
    if (this.mMAXBackwardDuration != null) {
      map.addAll({"mMAXBackwardDuration": this.mMAXBackwardDuration});
    }
    if (this.preferAudio != null) {
      map.addAll({"preferAudio": this.preferAudio});
    }
    if (this.enableHttpDns != null) {
      map.addAll({"enableHttpDns": this.enableHttpDns});
    }
    if (this.enableHttp3 != null) {
      map.addAll({"enableHttp3": this.enableHttp3});
    }
    if (this.enableStrictFlvHeader != null) {
      map.addAll({"enableStrictFlvHeader": this.enableStrictFlvHeader});
    }
    if (this.enableStrictAuthMode != null) {
      map.addAll({"enableStrictAuthMode": this.enableStrictAuthMode});
    }
    if (this.enableProjection != null) {
      map.addAll({"enableProjection": this.enableProjection});
    }
    return map;
  }

  /// Map类型的playConfig转为AVPConfig类型
  static AVPConfig convertAt(Map map) {
    AVPConfig config = AVPConfig();
    config.mMaxAllowedAbrVideoPixelNumber =
        map["mMaxAllowedAbrVideoPixelNumber"];
    config.maxDelayTime = map["maxDelayTime"];
    config.highBufferDuration = map["highBufferDuration"];
    config.startBufferDuration = map["startBufferDuration"];
    config.maxBufferDuration = map["maxBufferDuration"];
    config.networkTimeout = map["networkTimeout"];
    config.networkRetryCount = map["networkRetryCount"];
    config.maxProbeSize = map["maxProbeSize"];
    config.referer = map["referer"];
    config.userAgent = map["userAgent"];
    config.httpProxy = map["httpProxy"];
    config.clearShowWhenStop = map["clearShowWhenStop"];
    config.httpHeaders = map["httpHeaders"];
    config.enableSEI = map["enableSEI"];
    config.enableLocalCache = map["enableLocalCache"];
    config.pixelBufferOutputFormat = map["pixelBufferOutputFormat"];
    config.liveStartIndex = map["liveStartIndex"];
    config.disableAudio = map["disableAudio"];
    config.disableVideo = map["disableVideo"];
    config.positionTimerIntervalMs = map["positionTimerIntervalMs"];
    config.mMAXBackwardDuration = map["mMAXBackwardDuration"];
    config.preferAudio = map["preferAudio"];
    config.enableHttp3 = map["enableHttp3"];
    config.enableStrictFlvHeader = map["enableStrictFlvHeader"];
    config.enableStrictAuthMode = map["enableStrictAuthMode"];
    config.enableProjection = map["enableProjection"];
    return config;
  }
}

/// 是否支持的功能的类型
enum SupportFeatureType {
  /// 硬件是否支持杜比音频
  dolbyAudio,
}

/// 播放器音频设置选择
enum AliPlayerAudioSesstionType {
  /// 默认播放器SDK音频设置
  sdkDefault,

  /// 混音
  mix,

  /// 音频不设置，设置权交由客户自行选择，解决多个播放器可能产生的音频抢占问题
  none,
}
