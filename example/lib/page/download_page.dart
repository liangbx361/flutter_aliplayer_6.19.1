import 'dart:io';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/custom_downloader_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer_example/page/player_page.dart';
import 'package:flutter_aliplayer_example/util/aliyun_download_manager.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';
import 'package:flutter_aliplayer_example/util/database_utils.dart';
import 'package:flutter_aliplayer_example/util/formatter_utils.dart';
import 'package:flutter_aliplayer_example/util/network_utils.dart';
import 'package:flutter_aliplayer_example/widget/aliyun_download_dialog.dart';

typedef void AliDownloadManagerCreatedCallback();

class DownloadPage extends StatefulWidget {
  final AliDownloadManagerCreatedCallback onCreated;
  var _downloadPageState;

  DownloadPage({ required this.onCreated});

  @override
  _DownloadPageState createState() {
    _downloadPageState = _DownloadPageState();
    return _downloadPageState;
  }

  void showDownloadDialog() {
    _downloadPageState._showDownloadDialog();
    }
}

class _DownloadPageState extends State<DownloadPage> {
 late AliyunDownloadManager _aliyunDownloadManager;//AliyunDownloadManager

  // List<CustomDownloaderModel> _dataList = List<CustomDownloaderModel>();
  List<CustomDownloaderModel> _dataList = [];

  @override
  void initState() {
    super.initState();
    _aliyunDownloadManager = AliyunDownloadManager.instance;
    DBUtils.openDB().then((value) {
      _aliyunDownloadManager.findAllDownload().then((value) {
        setState(() {
          _dataList.addAll(value);
        });
      });
    });
  }

  _showDownloadDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AliyunDownloadDialog(
            onItemAdd: (data) {
              _aliyunDownloadManager.add(data).then((value) {
                setState(() {
                  _dataList.add(value);
                });
              }).catchError((e) {
                print("aliyun download error : $e");
              });
            },
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
              itemCount: _dataList.length == 0 ? 0 : _dataList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListViewItem(index);
              }),
        ],
      ),
    );
  }

  Widget _buildListViewItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                _dataList[index].coverUrl,
                width: 85.0,
                height: 85.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "images/default_cover.png",
                    width: 85.0,
                    height: 85.0,
                  );
                },
              ),
              Container(
                width: 85.0,
                height: 85.0,
                alignment: Alignment.center,
                child: Text(
                  _dataList[index].stateMsg,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dataList[index].title,
                  maxLines: 1,
                ),
                Text(
                  FormatterUtils.getFileSizeDescription(
                      _dataList[index].vodFileSize),
                  maxLines: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text("开始"),
                        onPressed: () {
                          CustomDownloaderModel customDownloaderModel =
                              _dataList[index];
                          if (customDownloaderModel.downloadState ==
                                  DownloadState.COMPLETE ||
                              customDownloaderModel.downloadState ==
                                  DownloadState.START) {
                          } else {
                            NetWorkUtils.instance
                                .getHttpFuture(HttpConstant.GET_STS, params: {})
                                .then((value) {
                              var map = {
                                DataSourceRelated.VID_KEY:
                                    customDownloaderModel.videoId,
                                DataSourceRelated.TYPE_KEY:
                                    FlutterAvpdef.DOWNLOADTYPE_STS,
                                DataSourceRelated.INDEX_KEY:
                                    customDownloaderModel.index,
                                DataSourceRelated.ACCESSKEYID_KEY:
                                    value["accessKeyId"],
                                DataSourceRelated.ACCESSKEYSECRET_KEY:
                                    value["accessKeySecret"],
                                DataSourceRelated.SECURITYTOKEN_KEY:
                                    value["securityToken"],
                              };
                              _aliyunDownloadManager
                                  .prepare(map)
                                  .whenComplete(() {
                                _aliyunDownloadManager
                                    .start(customDownloaderModel)
                                    .listen((event) {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                }, onDone: () {});
                              });
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: Text("停止"),
                        onPressed: () {
                          CustomDownloaderModel customDownloaderModel =
                              _dataList[index];
                          _aliyunDownloadManager
                              .stop(customDownloaderModel)!
                              .then((value) {
                            setState(() {
                              customDownloaderModel = value;
                            });
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: Text("播放"),
                        onPressed: () {
                          CustomDownloaderModel customDownloaderModel =
                              _dataList[index];
                          if (customDownloaderModel.downloadState ==
                              DownloadState.COMPLETE) {
                            if (Platform.isIOS) {
                              _aliyunDownloadManager
                                  .getFullSavePathForIOS(
                                      customDownloaderModel.savePath)
                                  .then((value) {
                                Map<String, String> dataSourcecMap = {
                                  DataSourceRelated.URL_KEY: value
                                };
                                CommomUtils.pushPage(
                                    context,
                                    PlayerPage(
                                        playMode: ModeType.URL,
                                        dataSourceMap: dataSourcecMap));
                              });
                            } else if (Platform.isAndroid) {
                              Map<String, String> dataSourcecMap = {
                                DataSourceRelated.URL_KEY:
                                    customDownloaderModel.savePath
                              };
                              CommomUtils.pushPage(
                                  context,
                                  PlayerPage(
                                      playMode: ModeType.URL,
                                      dataSourceMap: dataSourcecMap));
                            }
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        child: Text("删除"),
                        onPressed: () {
                          _aliyunDownloadManager
                              .delete(_dataList[index])
                              .then((value) {
                            setState(() {
                              _dataList.removeAt(index);
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
