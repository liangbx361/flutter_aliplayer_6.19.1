# flutter_aliplayer

A new flutter plugin project , The project supports Android and iOS base on AliyunPlayerSDK
[Android SDK URL](https://help.aliyun.com/document_detail/94328.html?spm=a2c4g.11186623.6.979.1d5c67b4gEmBvH)
[iOS SDK URL](https://help.aliyun.com/document_detail/94428.html?spm=a2c4g.11186623.6.980.7fc22a88xOI4gc)

## Installation

```yaml
dependencies:
  flutter_aliplayer: ^{{latest version}}
```

## 说明

  flutter 播放器在原生层是基于 Android 播放器 SDK 和 iOS 播放器 SDK 的。可能部分原生播放器 SDK 的接口有遗漏，在 flutter 播放器插件中没有暴露出来。目前我们已将源码提供出来，开发者可以自行添加。也可以通知给我们，我们会对遗漏的接口进行补充。

## 版本号规则

从 6.17.0 版本开始，我们将并行发布两种版本，请根据需求选择使用：

1. 版本号如 6.17.0：
   - 对应 SDK 内核为 **播放器独立SDK（AliPlayerSDK）**，适用于纯点播场景。
2. 版本号如 6.17.0-interactivelive：
   - 对应 SDK 内核为 **音视频终端SDK（AliVCSDK_InteractiveLive）**，适用于点播和直播场景。
   - 若配合推流插件 `flutter_livepush_plugin` 使用，请务必使用此版本，以避免 SDK 编译冲突。

此外，您可以在项目中修改 `useAIOFramework` 变量以动态切换 SDK 内核：

- 设置 `useAIOFramework = false`：使用播放器独立 SDK（默认）。
- 设置 `useAIOFramework = true`：使用音视频终端 SDK。

您还可以根据需要自行更改 SDK 内核版本：

* 设置 `player_sdk_version`：定义播放器独立 SDK 版本号。
* 设置 `aio_sdk_version`：定义音视频终端 SDK 版本号。

请根据具体需求进行选择和调整，以确保最佳使用体验。

## AliPlayer

### 1. 播放控制

```dart
  ///1、创建播放器
  FlutterAliplayer fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
  ///多实例播放器创建方式，需要 flutter 层管理 playerId，其他接口一样，在播放器的回调中会返回对应的 playerId 来通知 flutter 层是哪一个播放器对象
  //FlutterAliplayer fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: playerId);

  ///2、设置监听,只列举了部分接口，更多接口可以参考播放器 Android\iOS 接口文档
  ///准备成功
  fAliplayer.setOnPrepared((playerId) {});
  ///首帧显示
  fAliplayer.setOnRenderingStart((playerId) {});
  ///视频宽高变化
  fAliplayer.setOnVideoSizeChanged((width, height,playerId) {});
  ///播放器状态变化
  fAliplayer.setOnStateChanged((newState,playerId) {});
  ///加载状态
  fAliplayer.setOnLoadingStatusListener(
      loadingBegin: (playerId) {},
      loadingProgress: (percent, netSpeed,playerId) {},
      loadingEnd: (playerId) {});
  ///拖动完成
  fAliplayer.setOnSeekComplete((playerId) {});
  ///播放器事件信息回调，包括 buffer、当前播放进度 等等信息，根据 infoCode 来判断，对应 FlutterAvpdef.infoCode
  fAliplayer.setOnInfo((infoCode, extraValue, extraMsg,playerId) {});
  ///播放完成
  fAliplayer.setOnCompletion((playerId) {});
  ///设置流准备完成
  fAliplayer.setOnTrackReady((playerId) {});
  ///截图结果
  fAliplayer.setOnSnapShot((path,playerId) {});
  ///错误结果
  fAliplayer.setOnError((errorCode, errorExtra, errorMsg,playerId) {});
  ///切换流变化
  fAliplayer.setOnTrackChanged((value,playerId) {});

  ///3、设置渲染的 View
  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;

    var height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    AliPlayerView aliPlayerView = AliPlayerView(
        onCreated: onViewPlayerCreated,
        x: x,
        y: y,
        width: width,
        height: height);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Scaffold(
          body: Column(
            children: [
              Container(
                  color: Colors.black,
                  child: aliPlayerView,
                  width: width,
                  height: height),
            ],
          ),
        );
      },
    );
  }

    ///4、设置播放源
    ///说明：STS 播放方式，vid、region、accessKeyId、accessKeySecret、securityToken 为必填，其他参数可选
    ///     AUTH 播放方式，vid、region、playAuth 为必填，其他参数可选
    /// 每个 Map 对应的key 在 flutter 的 Demo 的 config.dart 中查看，fAliplayer 为播放器对象，如果还未创建，参考后续文档创建播放器
  void onViewPlayerCreated(viewId) async {
    ///将 渲染 View 设置给播放器
    fAliplayer.setPlayerView(viewId);
    //设置播放源
    FlutterAliplayer.createVidPlayerConfigGenerator();
    // 设置预览时间
    FlutterAliplayer.setPreviewTime(
        int.parse(_dataSourceMap[DataSourceRelated.PREVIEWTIME_KEY]));
    String playConfig = await FlutterAliplayer.generatePlayerConfig();

    switch (_playMode) {
      //URL 播放方式
      case ModeType.URL:
        this.fAliplayer.setUrl(_dataSourceMap[DataSourceRelated.URL_KEY]);
        break;
      //STS 播放方式
      case ModeType.STS:
        this.fAliplayer.setVidSts(
            vid: _dataSourceMap[DataSourceRelated.VID_KEY],
            region: _dataSourceMap[DataSourceRelated.REGION_KEY],
            accessKeyId: _dataSourceMap[DataSourceRelated.ACCESSKEYID_KEY],
            accessKeySecret:
                _dataSourceMap[DataSourceRelated.ACCESSKEYSECRET_KEY],
            securityToken: _dataSourceMap[DataSourceRelated.SECURITYTOKEN_KEY],
            definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
            playConfig: playConfig);
        break;
      //AUTH 播放方式
      case ModeType.AUTH:
        this.fAliplayer.setVidAuth(
            vid: _dataSourceMap[DataSourceRelated.VID_KEY],
            region: _dataSourceMap[DataSourceRelated.REGION_KEY],
            playAuth: _dataSourceMap[DataSourceRelated.PLAYAUTH_KEY],
            definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
            previewTime: _dataSourceMap[DataSourceRelated.PREVIEWTIME_KEY]);
        break;
      default:
    }
  }

  ///可选步骤:开启自动播放，默认关闭
  fAliplayer.setAutoPlay(true);
  ///5、prepare
  fAliplayer.prepare();
  ///说明：如果开启了自动播放，则调用 prepare 后即可，播放器在 prepare 成功后会自动播放，如果未开启自动播放，则需要在 setOnPrepard() 准备成功回调中，调用 fAliplayer.play() 开始播放

//暂停播放
///暂停播放后，恢复播放直接调用 play 即可
fAliplayer.pause();

//停止播放
///停止播放后，恢复播放需要重新走一遍播放流程：prepare --> play
fAliplayer.stop();

//销毁
fAliplayer.release();

//seek
///seekMode 可选值：FlutterAvpdef.ACCURATE(精准seek) 和 FlutterAvpdef.INACCURATE(非精准seek)
fAliplayer.seek(position,seekMode);

//循环播放
fAliplayer.setLoop(true);

//静音、音量控制
fAliplayer.setMute(true);
///设置播放器音量,范围0~1.
fAliPlayer.setVolume(1);

//倍速播放
///可选值：0.5，1.0，1.5，2.0
fAliplayer.setRate(1.0);

//切换多码率，自动码率切换
///在prepare成功之后，通过getMediaInfo可以获取到各个码流的信息，即TrackInfo
fAliplayer.getMediaInfo().then((value) {
//value 为 map，value['tracks'] 可以获取对应的 TrackInfos 列表信息，可以参考 Demo 中 AVPMediaInfo info = AVPMediaInfo.fromJson(value); 如何解析 TrackInfo
};
///在播放过程中，可以通过调用播放器的selectTrack方法切换播放的码流,参数为 TrackInfo 中的 trackIndex，切换的结果会在OnTrackChangedListener监听之后会回调
fAliplayer.selectTrack(index);
  
///自动码率切换
fAliplayer.selectTrack(-1);

//画面旋转、填充、镜像操作
//设置画面的镜像模式：水平镜像，垂直镜像，无镜像。
fAliplayer.setMirrorMode(FlutterAvpdef.AVP_MIRRORMODE_NONE);
//设置画面旋转模式：旋转0度，90度，180度，270度
fAliplayer.setRotateMode(FlutterAvpdef.AVP_ROTATE_0);
//设置画面缩放模式：宽高比填充，宽高比适应，拉伸填充
fAliplayer.setScalingMode(FlutterAvpdef.AVP_SCALINGMODE_SCALETOFILL);
```

### 2. 边播边缓存

  需要在 prepare 之前设置给播放器

```dart
var map = {
  "mMaxSizeMB": _mMaxSizeMBController.text,///缓存目录的最大占用空间
  "mMaxDurationS": _mMaxDurationSController.text,///设置能够缓存的单个文件的最大时长
  "mDir": _mDirController.text,///缓存目录
  "mEnable": mEnableCacheConfig,///是否开启缓存功能
};
fAliplayer.setCacheConfig(map);
```

### 3. 播放器其他配置

 需要在 prepare 之前设置给播放器

```dart
var configMap = {
  'mStartBufferDuration':_mStartBufferDurationController.text,///起播缓冲区时长
  'mHighBufferDuratio':_mHighBufferDurationController.text,///高缓冲时长
  'mMaxBufferDuration':_mMaxBufferDurationController.text,///最大缓冲区时长
  'mMaxDelayTime': _mMaxDelayTimeController.text,///最大延迟。注意：直播有效
  'mNetworkTimeout': _mNetworkTimeoutController.text,///网络超时时间
  'mNetworkRetryCount':_mNetworkRetryCountController.text,///网络重试次数
  'mMaxProbeSize': _mMaxProbeSizeController.text,///最大probe大小
  'mReferrer': _mReferrerController.text,///referrer
  'mHttpProxy': _mHttpProxyController.text,///http代理
  'mEnableSEI': mEnableSEI,///是否启用SEI
  'mClearFrameWhenStop': !mShowFrameWhenStop,///停止后是否清空画面
  'mDisableVideo': mDisableVideo,///禁用Video
  'mDisableAudio': mDisableAudio///禁用Audio
};
widget.fAliplayer.setConfig(configMap);
```

## AliListPlayer

```dart
//1.创建列表播放器
FlutterAliListPlayer fAliListPlayer = FlutterAliPlayerFactory.createAliListPlayer();

//2.添加资源、移除资源。列表播放器目前只支持两种播放方式，URL 和 STS    
///uid是视频的唯一标志。用于区分视频是否一样。如果uid一样，则认为是一样的
fAliListPlayer.addUrlSource(url,uid);
fAliListPlayer.addVidSource(vid,uid);
fAliListPlayer.removeSource(uid);

//设置预加载个数
fAliListPlayer.setPreloadCount(count);

//播放视频源
///uid 为必填项，如果是 URL 播放方式，只需要 uid 即可，如果是 STS 方式，则需要填写 STS 信息
fAliListPlayer.moveTo();
```

## AliLiveShiftPlayer

```dart
//创建直播时移播放器
FlutterAliLiveShiftPlayer _flutterAliLiveShiftPlayer = FlutterAliPlayerFactory.createAliLiveShiftPlayer();

//设置渲染 View
@override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;

    var height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    AliPlayerView aliPlayerView = AliPlayerView(
        onCreated: onViewPlayerCreated,
        x: x,
        y: y,
        width: width,
        height: height);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin for LiveShiftPlayer'),
      ),
      body: Column(children: [
        Container(
          width: width,
          height: height,
          child: aliPlayerView,
        ),
      ]),
    );
  }

///setPlayerView(viewId) 给播放器设置渲染 View
///setDataSource(timelineUrl,url) 设置播放源，其中 url 为播放地址，timelineurl 为时移请求地址
void onViewPlayerCreated(int viewId) {
    this._flutterAliLiveShiftPlayer.setPlayerView(viewId);
    int time = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    var timeLineUrl =
        "$_timeLineUrl&lhs_start_unix_s_0=${time - 5 * 60}&lhs_end_unix_s_0=${time + 5 * 60}";
    _flutterAliLiveShiftPlayer.setDataSource(timeLineUrl, _url);
  }
}

///时移到某个时间
_flutterAliLiveShiftPlayer.seekToLiveTime();

///获取当前直播的播放时间
flutterAliLiveShiftPlayer.getCurrentTime().then((value) {});

///获取当前直播的现实时间
_flutterAliLiveShiftPlayer.getCurrentLiveTime().then((value) {});

///准备
_flutterAliLiveShiftPlayer.prepare();

///开始播放
_flutterAliLiveShiftPlayer.play();

///停止
_flutterAliLiveShiftPlayer?.stop();
///销毁
_flutterAliLiveShiftPlayer?.destroy();

///时移seek完成通知。playerTime:实际播放的时间
_flutterAliLiveShiftPlayer.setOnSeekLiveCompletion(playTime, playerId) {});

//时移时间更新监听事件。currentTime - 当前现实时间，shiftStartTime - 可时移的起始时间，shiftEndTime - 可时移的结束时间
_flutterAliLiveShiftPlayer.setOnTimeShiftUpdater((currentTime, shiftStartTime, shiftEndTime, playerId) {});
```



## 下载

  可选步骤,如果是安全下载，需要配置自己的加密校验文件到 SDK 中，普通下载则不需要

```dart
//配置加密校验文件，尽可能提前配置(可选)  
FlutterAliPlayerFactory.initService(byteData);

//创建下载器
FlutterAliDownloader donwloader = FlutterAliDownloader.init();
///设置保存路径
donwloader.setSaveDir(path)

//开始下载
///1.prepare
///参数说明：type 可选值为 FlutterAvpdef.DOWNLOADTYPE_STS / FlutterAvpdef.DOWNLOADTYPE_AUTH 。当 type 为 DOWNLOADTYPE_STS 时候，必填参数为： {vid,accessKeyId,accessKeySecret,securityToken}，当 type 为 DOWNLOADTYPE_AUTH 时，必须填参数为 {vid,playAuth}
  downloader.prepare(type, vid).then((value) {
      //value 为 map，对应 Demo 中的 DownloadModel 自定义下载类
      DownloadModel downloadModel = DownloadModel.fromJson(value);
      //2.selectItem，根据不同的 trackInfo 来确定需要下载哪个清晰度
      List<TrackInfoModel> trackInfos = downloadModel.trackInfos;
      downloader.selectItem(vid,trackInfos[0].index);
      //3.start
      downloader.start(vid, trackInfos[0].index).listen((event) {
        //说明：event 可能会有多种信息,可参考 FlutterAvpdef.EventChanneldef 中的信息，以下为具体说明：
        if (event[EventChanneldef.TYPE_KEY] == EventChanneldef.DOWNLOAD_PROGRESS){
            //下载进度百分比信息，获取下载进度百分比：event[EventChanneldef.DOWNLOAD_PROGRESS]
        }else if(event[EventChanneldef.TYPE_KEY] == EventChanneldef.DOWNLOAD_PROCESS){
            //处理进度百分比信息，获取处理进度百分比：event[EventChanneldef.DOWNLOAD_PROCESS]
        }else if(event[EventChanneldef.TYPE_KEY] == EventChanneldef.DOWNLOAD_COMPLETION){
            //下载完成，可以通过 event['vid']、event['index'] 获取对应的 vid 和 index 用于判断是哪个视频下载完成，event['savePath'] 用于获取下载完成视频的本地路径

            // 'savePath'在iOS中是相对路径，每次进行播放时可以通过调用getFullSaveForIOS('savePath')进行获取全路径，保证路径获取的正确性，安卓直接使用就可以
            if (Platform.isIOS) {
              donwloader.getFullSavePathForIOS(event['savePath']).then((value) {
                // value是最新的全路径，可以拿这个路径去播放
              });
            }
        }else if(event[EventChanneldef.TYPE_KEY] == EventChanneldef.DOWNLOAD_ERROR){
            //下载失败，可以通过 event['vid']、event['index'] 获取对应的 vid 和 index 用于判断是哪个视频下载失败，event['errorCode']、event['errorMsg'] 可以获取对应的错误码，和错误信息
        }
      });
  });

//停止下载、删除和释放
downloader.stop(vid, index)
//可以删除下载的本地文件
downloader.delete(vid, index)
downloader.release(vid, index)
```

## 加载 RtsSDK
如果需要支持 artc 协议，首先需要引入如下两个插件：
```yaml
//flutter_aliplayer_artc: 对应版本号
//flutter_aliplayer_rts: 对应版本号

```

Android 在build.gradle中添加依赖即可
```
dependencies{
    implementation 'com.aliyun.aio:AliVCSDK_InteractiveLive:$version'
}
```

iOS在Podfile文件中添加依赖即可
```
target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  pod 'AliVCSDK_InteractiveLive', '$version'

end
```


Android 需要额外调用如下代码(尽可能提前)：
```dart
FlutterAliPlayerFactory.loadRtsLibrary();
```