import 'dart:async';
import 'dart:io';

import 'package:flutter_aliplayer/flutter_alidownloader.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/custom_downloader_model.dart';
import 'package:flutter_aliplayer_example/util/database_utils.dart';
import 'package:path_provider/path_provider.dart';

class AliyunDownloadManager {
  static AliyunDownloadManager _instance =
  AliyunDownloadManager._privateConstructor();
  FlutterAliDownloader? _flutterAliDownloader;
  late DBUtils _dbUtils;

  //下载保存地址
  String? _downloadSavePath;


  //prepared集合
  List<CustomDownloaderModel> _preparedList = <CustomDownloaderModel>[];

  Map<String, StreamController> _controllerMap = Map();

  static AliyunDownloadManager get instance {
    return _instance;
  }

  AliyunDownloadManager._privateConstructor() {
    _dbUtils = DBUtils.instance;
    _flutterAliDownloader = FlutterAliDownloader.init();

    if (Platform.isAndroid) {
      getExternalStorageDirectories().then((value) {
        if (value!.length > 0) {
          _downloadSavePath = value[0].path + "/download/";
          return Directory(_downloadSavePath!);
        }
      }).then((value) {
        return value!.exists();
      }).then((value) {
        if (!value) {
          Directory directory = Directory(_downloadSavePath!);
          directory.create();
        }
        return _downloadSavePath;
      }).then((value) {
        _flutterAliDownloader?.setSaveDir(_downloadSavePath!);
      });
    } else if (Platform.isIOS) {
      //TODO  IOS
      _flutterAliDownloader?.setSaveDir('download');
    }
  }

  ///比较两个对象是否相等
  bool _compareTo(CustomDownloaderModel src, CustomDownloaderModel dst) {
    return src.videoId == dst.videoId && src.vodDefinition == dst.vodDefinition;
  }

  Future<List<CustomDownloaderModel>> findAllDownload() {
    return _dbUtils.selectAll().then((value) {
      if (_preparedList.length > 0) {
        _preparedList.clear();
      }
      value.forEach((element) {
        CustomDownloaderModel customDownloaderModel =
        CustomDownloaderModel.fromJson(element);
        if (customDownloaderModel.downloadState != DownloadState.COMPLETE) {
          customDownloaderModel.downloadState = DownloadState.PREPARE;
          customDownloaderModel.stateMsg = "准备完成";
        }
        _preparedList.add(customDownloaderModel);
      });
      return _preparedList;
    });
  }

  Future<dynamic> prepare(Map map) {
    return _flutterAliDownloader!
        .prepare(
        map[DataSourceRelated.TYPE_KEY], map[DataSourceRelated.VID_KEY],
        accessKeyId: map[DataSourceRelated.ACCESSKEYID_KEY],
        accessKeySecret: map[DataSourceRelated.ACCESSKEYSECRET_KEY],
        securityToken: map[DataSourceRelated.SECURITYTOKEN_KEY],
        playAuth: map[DataSourceRelated.PLAYAUTH_KEY],
        index: map[DataSourceRelated.INDEX_KEY])
        .then((value) {
      return value;
    });
  }

  Future<dynamic> add(CustomDownloaderModel customDownloaderModel) async {
    await Future.forEach(_preparedList, (element) {
      if (_compareTo(element, customDownloaderModel)) {
        return Future.error(
            '${customDownloaderModel.videoId} , ${customDownloaderModel
                .vodDefinition}  has added');
      }
    });
    var json = customDownloaderModel.toJson();
    _preparedList.add(customDownloaderModel);
    _flutterAliDownloader?.selectItem(
        customDownloaderModel.videoId, customDownloaderModel.index);
    _dbUtils.insert(json);
    return Future.value(customDownloaderModel);
  }

  Stream<dynamic> start(CustomDownloaderModel customDownloaderModel) {
    String key = customDownloaderModel.videoId +
        '_' +
        customDownloaderModel.index.toString();
    StreamController? _controller = _controllerMap[key];
    if(_controller==null){
        _controller=StreamController<dynamic>();
        _controllerMap.putIfAbsent(key,()=>_controller!);
    }

    StreamController<dynamic> _callbackController = StreamController();
    StreamSink<dynamic> _sink = _callbackController.sink;
    customDownloaderModel.downloadState = DownloadState.START;
    _controller.addStream(_flutterAliDownloader!.start(
        customDownloaderModel.videoId, customDownloaderModel.index)!);
    if (!_controller.hasListener) {
      _controller.stream.listen((event) {
        if (event[EventChanneldef.TYPE_KEY] ==
            EventChanneldef.DOWNLOAD_PROGRESS &&
            customDownloaderModel.videoId == event['vid'] &&
            customDownloaderModel.index == event['index'] &&
            customDownloaderModel.downloadState != DownloadState.STOP) {
          //调用stop后,放置event时间消息继续发送,而导致其实已经停止了下载,但是界面还是在继续消费管道中的下载进度消息
          customDownloaderModel.stateMsg =
              event[EventChanneldef.DOWNLOAD_PROGRESS] + "%";
          _sink.add(customDownloaderModel);
        } else if (event[EventChanneldef.TYPE_KEY] ==
            EventChanneldef.DOWNLOAD_PROCESS &&
            customDownloaderModel.videoId == event['vid'] &&
            customDownloaderModel.index == event['index']) {
          customDownloaderModel.stateMsg = "ProcessingProgress \n" +
              event[EventChanneldef.DOWNLOAD_PROGRESS] +
              "%";
          _sink.add(customDownloaderModel);
        } else if (event[EventChanneldef.TYPE_KEY] ==
            EventChanneldef.DOWNLOAD_COMPLETION &&
            customDownloaderModel.videoId == event['vid'] &&
            customDownloaderModel.index == event['index']) {
          customDownloaderModel.downloadState = DownloadState.COMPLETE;
          customDownloaderModel.stateMsg = "下载完成";
          customDownloaderModel.savePath = event['savePath'];

          _dbUtils.update(customDownloaderModel.toJson());
          _sink.add(customDownloaderModel);
          String key = customDownloaderModel.videoId +
              '_' +
              customDownloaderModel.index.toString();
          _controllerMap.remove(key);
        } else if (event[EventChanneldef.TYPE_KEY] ==
            EventChanneldef.DOWNLOAD_ERROR &&
            customDownloaderModel.videoId == event['vid'] &&
            customDownloaderModel.index == event['index']) {
          customDownloaderModel.downloadState = DownloadState.ERROR;
          print(
              "aliyun : download_error --- ${event['errorCode']}  ------   ${event['errorMsg']}");
          customDownloaderModel.stateMsg = event['errorMsg'];
          _sink.add(customDownloaderModel);
        }
      });
    }

    return _callbackController.stream;
  }

  Future<dynamic>? stop(CustomDownloaderModel customDownloaderModel) {
    if (customDownloaderModel.downloadState == DownloadState.START ||
        customDownloaderModel.downloadState == DownloadState.PREPARE) {
      _flutterAliDownloader?.stop(
          customDownloaderModel.videoId, customDownloaderModel.index);
      customDownloaderModel.downloadState = DownloadState.STOP;
      customDownloaderModel.stateMsg = "暂停下载";
      String key = customDownloaderModel.videoId +
          '_' +
          customDownloaderModel.index.toString();
      _controllerMap.remove(key);
      return Future.value(customDownloaderModel);
    }

    return null;
  }

  Future<dynamic> delete(CustomDownloaderModel customDownloaderModel) {
    var map = customDownloaderModel.toJson();
    _preparedList.remove(customDownloaderModel);
    _dbUtils.delete(map);
    _flutterAliDownloader?.delete(
        customDownloaderModel.videoId, customDownloaderModel.index);
    _flutterAliDownloader?.release(
        customDownloaderModel.videoId, customDownloaderModel.index);
    String key = customDownloaderModel.videoId +
        '_' +
        customDownloaderModel.index.toString();
    _controllerMap.remove(key);
    return Future.value(customDownloaderModel);
  }

  Future<dynamic> getFullSavePathForIOS(String savePath) {
    return _flutterAliDownloader!.getFullSaveForIOS(savePath);
  }
}
