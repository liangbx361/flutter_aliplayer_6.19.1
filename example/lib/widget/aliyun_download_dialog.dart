import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_alidownloader.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/custom_downloader_model.dart';
import 'package:flutter_aliplayer_example/model/downloader_model.dart';
import 'package:flutter_aliplayer_example/util/aliyun_download_manager.dart';
import 'package:flutter_aliplayer_example/util/formatter_utils.dart';
import 'package:flutter_aliplayer_example/util/network_utils.dart';

///add Downnload item Dialog
class AliyunDownloadDialog extends Dialog {
  final NetWorkUtils _netWorkUtils = NetWorkUtils.instance;
  final TextEditingController _vidController = TextEditingController.fromValue(
      TextEditingValue(text: DataSourceRelated.DEFAULT_VID));
  final TextEditingController _accessKeyIdController = TextEditingController();
  final TextEditingController _accessKeySecretController =
      TextEditingController();
  final TextEditingController _securityTokenController =
      TextEditingController();
  final TextEditingController _playAuthController = TextEditingController();

  AliyunDownloadManager? _aliyunDownloadManager; //AliyunDownloadManager
  DownloadModel? _downloadModel; //DownloadModel

  var onItemAdd;
  var onClose;

  //当前选中的下标
  int _selectedIndex = -1;
  ModeType _mCurrentModeType = ModeType.STS;

  AliyunDownloadDialog({this.onItemAdd, this.onClose});

  @override
  Widget build(BuildContext context) {
    _aliyunDownloadManager = AliyunDownloadManager.instance;
    var _dialogWidth = MediaQuery.of(context).size.width * 0.90;
    var _dialogHeight = MediaQuery.of(context).size.height * 0.70;
    return Material(
        type: MaterialType.transparency,
        child: StatefulBuilder(builder: (context, state) {
          return Center(
            child: Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              width: _dialogWidth,
              height: _dialogHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    //vid
                    TextField(
                      controller: _vidController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "vid",
                      ),
                    ),

                    //AccessKeyId
                    TextField(
                      controller: _accessKeyIdController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "AccessKeyId",
                      ),
                    ),

                    //AccessKeySecret
                    TextField(
                      controller: _accessKeySecretController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "AccessKeySecret",
                      ),
                    ),

                    //SecurityToken
                    TextField(
                      controller: _securityTokenController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "SecurityToken",
                      ),
                    ),

                    //PlayAuth
                    TextField(
                      controller: _playAuthController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "PlayAuth",
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text("sts"),
                            onPressed: () {
                              _mCurrentModeType = ModeType.STS;
                              _requestStsInfo(state);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text("auth"),
                            onPressed: () {
                              _mCurrentModeType = ModeType.AUTH;
                              _requestAuthInfo(state);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text("add"),
                            onPressed: () {
                              if (_selectedIndex >= 0) {
                                TrackInfoModel trackInfoModel =
                                    _downloadModel?.trackInfos[_selectedIndex];
                                CustomDownloaderModel customDownloaderModel =
                                    CustomDownloaderModel(
                                        videoId: _downloadModel?.videoId,
                                        title: _downloadModel?.title,
                                        coverUrl: _downloadModel?.coverUrl,
                                        index: trackInfoModel.index,
                                        vodDefinition:
                                            trackInfoModel.vodDefinition,
                                        vodFileSize: trackInfoModel.vodFileSize,
                                        vodFormat: trackInfoModel.vodFormat,
                                        stateMsg: "准备完成",
                                        downloadModeType: _mCurrentModeType,
                                        downloadState: DownloadState.PREPARE,
                                        savePath: '');
                                onItemAdd(customDownloaderModel);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text("Close"),
                            onPressed: () {
                              onClose();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    _buildDownloadItem(state),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  ///STS info request
  void _requestStsInfo(StateSetter setState) {
    _netWorkUtils.getHttp(HttpConstant.GET_STS, successCallback: (data) {
      _accessKeyIdController.text = data["accessKeyId"];
      _accessKeySecretController.text = data["accessKeySecret"];
      _securityTokenController.text = data["securityToken"];
      var map = {
        DataSourceRelated.TYPE_KEY: FlutterAvpdef.DOWNLOADTYPE_STS,
        DataSourceRelated.VID_KEY: _vidController.text,
        DataSourceRelated.ACCESSKEYID_KEY: _accessKeyIdController.text,
        DataSourceRelated.ACCESSKEYSECRET_KEY: _accessKeySecretController.text,
        DataSourceRelated.SECURITYTOKEN_KEY: _securityTokenController.text,
      };

      _aliyunDownloadManager?.prepare(map).then((value) {
        setState(() {
          print("loggin DownloadModel STS");
          print(value);
          _downloadModel = DownloadModel.fromJson(json.decode(value));
        });
      });
    }, errorCallback: (error) {
      print("error");
    }, params: {});
  }

  ///auth info request
  void _requestAuthInfo(StateSetter setState) {
    var params = {"videoId": _vidController.text};
    _netWorkUtils.getHttp(HttpConstant.GET_AUTH, params: params,
        successCallback: (data) {
      _playAuthController.text = data["playAuth"];
      var map = {
        DataSourceRelated.TYPE_KEY: FlutterAvpdef.DOWNLOADTYPE_AUTH,
        DataSourceRelated.VID_KEY: _vidController.text,
        DataSourceRelated.PLAYAUTH_KEY: _playAuthController.text,
      };
      _aliyunDownloadManager?.prepare(map).then((value) {
        print("Flutter Download" + value.toString());
        setState(() {
          print("loggin DownloadModel AUTH");
          print(value);
          _downloadModel = DownloadModel.fromJson(json.decode(value));
        });
      });

    }, errorCallback: (error) {
      print("Flutter Error" + error.toString());
    });
  }

  ///download item
  Widget _buildDownloadItem(StateSetter state) {
    if (null != _downloadModel && (null != _downloadModel?.trackInfos)) {
      return Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 3.5),
          itemBuilder: (BuildContext context, int index) {
            TrackInfoModel _trrackInfoModel = _downloadModel?.trackInfos[index];
            String size = FormatterUtils.getFileSizeDescription(
                _trrackInfoModel.vodFileSize);
            String title = _trrackInfoModel.vodDefinition +
                "\{${_trrackInfoModel.vodFormat}, $size\}";
            return Row(
              children: [
                Radio(
                    value: index,
                    groupValue: _selectedIndex,
                    onChanged: (e) {
                      state(() {
                        _selectedIndex = e!;
                      });
                    }),
                Expanded(
                    child: Text(
                  title,
                  maxLines: 2,
                )),
              ],
            );
          },
          itemCount: _downloadModel?.trackInfos.length,
        ),
      );
    } else {
      return Expanded(
        child: SizedBox(
          width: 10.0,
          height: 20.0,
        ),
      );
    }

    //
    // return Expanded(child: SizedBox(width: 10.0,height: 20.0,child: Text("视图测试"),));

    // if (_downloadModel?.trackInfos.length == 0) {
    //   return Expanded(
    //     child: SizedBox(
    //       width: 10.0,
    //       height: 20.0,
    //     ),
    //   );
    // } else {
    //   return Expanded(
    //     child: GridView.builder(
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 2, childAspectRatio: 3.5),
    //       itemBuilder: (BuildContext context, int index) {
    //         TrackInfoModel _trrackInfoModel = _downloadModel?.trackInfos[index];
    //         String size = FormatterUtils.getFileSizeDescription(
    //             _trrackInfoModel.vodFileSize);
    //         String title = _trrackInfoModel.vodDefinition +
    //             "\{${_trrackInfoModel.vodFormat}, $size\}";
    //         return Row(
    //           children: [
    //             Radio(
    //                 value: index,
    //                 groupValue: _selectedIndex,
    //                 onChanged: (e) {
    //                   state(() {
    //                     _selectedIndex = e!;
    //                   });
    //                 }),
    //             Expanded(
    //                 child: Text(
    //               title,
    //               maxLines: 2,
    //             )),
    //           ],
    //         );
    //       },
    //       itemCount: _downloadModel?.trackInfos.length,
    //     ),
    //   );
    // }
  }
}
