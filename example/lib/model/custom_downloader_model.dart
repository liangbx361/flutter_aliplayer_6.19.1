import 'package:flutter_aliplayer_example/config.dart';

///自定义下载类
class CustomDownloaderModel {
  static const String VID = "mVideoId";
  static const String TITLE = "mTitle";
  static const String COVERURL = "mCoverUrl";
  static const String INDEX = "mIndex";
  static const String FILESIZE = "mVodFileSize";
  static const String FORMAT = "mVodFormat";
  static const String DEFINITION = "mVodDefinition";
  static const String SAVEPATH = "mSavePath";
  static const String DOWNLOADMSG = "mDownloadMsg";
  static const String DOWNLOADMODETYPE = "mDownloadModeType";
  static const String DOWNLOADSTATE = "mDownloadState";

  var videoId;
  var title;
  var coverUrl;
  var index;
  var vodFileSize;
  var vodFormat;
  var vodDefinition;
  var savePath;
  var stateMsg;
  var downloadModeType;
  var downloadState;

  CustomDownloaderModel(
      {required this.videoId,
      required this.title,
      required this.coverUrl,
      required this.index,
      required this.vodFileSize,
      required this.vodFormat,
      required this.vodDefinition,
      required this.savePath,
      this.stateMsg = '准备完成',
      required this.downloadModeType,
      required this.downloadState});

  CustomDownloaderModel.fromJson(Map<String, dynamic> jsonMap) {
    this.videoId = jsonMap[VID];
    this.title = jsonMap[TITLE];
    this.coverUrl = jsonMap[COVERURL];
    this.index = jsonMap[INDEX];
    this.vodFileSize = num.parse(jsonMap[FILESIZE]) as int;
    this.vodFormat = jsonMap[FORMAT];
    this.vodDefinition = jsonMap[DEFINITION];
    this.stateMsg = jsonMap[DOWNLOADMSG];
    this.savePath = jsonMap[SAVEPATH];
    int state = jsonMap[DOWNLOADSTATE];
    if (state == DownloadState.PREPARE.index) {
      this.downloadState = DownloadState.PREPARE;
    } else if (state == DownloadState.START.index) {
      this.downloadState = DownloadState.START;
    } else if (state == DownloadState.STOP.index) {
      this.downloadState = DownloadState.STOP;
    } else if (state == DownloadState.COMPLETE.index) {
      this.downloadState = DownloadState.COMPLETE;
    } else {
      this.downloadState = DownloadState.ERROR;
    }
    int modeState = jsonMap[DOWNLOADMODETYPE];
    if (modeState == ModeType.STS.index) {
      this.downloadModeType = ModeType.STS;
    } else if (modeState == ModeType.AUTH.index) {
      this.downloadModeType = ModeType.AUTH;
    } else {
      this.downloadModeType = ModeType.STS;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data[VID] = this.videoId;
    data[TITLE] = this.title;
    data[COVERURL] = this.coverUrl;
    data[INDEX] = this.index;
    data[FILESIZE] = this.vodFileSize;
    data[FORMAT] = this.vodFormat;
    data[DEFINITION] = this.vodDefinition;
    data[SAVEPATH] = this.savePath;
    data[DOWNLOADMSG] = this.stateMsg;
    data[DOWNLOADSTATE] = this.downloadState.index;
    data[DOWNLOADMODETYPE] = this.downloadModeType.index;
    return data;
  }
}

enum DownloadState { PREPARE, START, STOP, COMPLETE, ERROR }
