import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingHomePageState createState() => _SettingHomePageState();
}

class _SettingHomePageState extends State<SettingPage> {
  TextEditingController _dnsTextEditingController = TextEditingController();
  TextEditingController _mLocalCacheDirController = TextEditingController();
  TextEditingController _mLocalCacheMaxLocalSizeController =
  TextEditingController();
  TextEditingController _mLocalCacheExpirationController =
  TextEditingController();
  TextEditingController _mLocalCacheMaxCacheCapacityController =
  TextEditingController();
  TextEditingController _mLocalCacheMinDiskCapacityController =
  TextEditingController();
  var _sdkVersion;
  List<String> _playerName = [];
  String _currentPlayerName = "Default";

  //保存地址
  var _savePath;

  //iOS保存沙盒目录类型。安卓默认设置DocTypeForIOS.documents供参数传递
  DocTypeForIOS _saveDocTypeForIOS = DocTypeForIOS.documents;
  var _mLogLevel;

  @override
  void initState() {
    super.initState();

    _mLogLevel = GlobalSettings.mLogLevel;

    if (GlobalSettings.mPlayerName.isNotEmpty) {
      _currentPlayerName = GlobalSettings.mPlayerName;
    }
    _playerName.add("Default");
    if (Platform.isAndroid) {
      _playerName.add("SuperMediaPlayer");
      _playerName.add("ExoPlayer");
      _playerName.add("MediaPlayer");
    }
    if (Platform.isIOS) {
      _playerName..add("SuperMediaPlayer")..add("AppleAVPlayer");
    }

    if (Platform.isAndroid) {
      getExternalStorageDirectories().then((value) {
        if (value!.length > 0) {
          _savePath = value[0].path + "/localCache/";
          return Directory(_savePath);
        }
      }).then((value) {
        return value!.exists();
      }).then((value) {
        if (!value) {
          Directory directory = Directory(_savePath);
          directory.create();
        }
        return _savePath;
      }).then((value) {
        _mLocalCacheDirController.text = _savePath;
      });
    } else if (Platform.isIOS) {
      _savePath = "localCache";
      _saveDocTypeForIOS = DocTypeForIOS.documents;
      _mLocalCacheDirController.text = _savePath;
      GlobalSettings.mCacheDir = _savePath;
      GlobalSettings.mDocTypeForIOS = _saveDocTypeForIOS;
    }

    _mLocalCacheDirController.text = GlobalSettings.mCacheDir;
    _mLocalCacheMaxLocalSizeController.text = GlobalSettings.mMaxCacheSize;
    _mLocalCacheExpirationController.text = GlobalSettings.mExpiration;
    _mLocalCacheMaxCacheCapacityController.text = GlobalSettings.mMaxCapacity;
    _mLocalCacheMinDiskCapacityController.text =
        GlobalSettings.mMinDiskCapacity;

    FlutterAliplayer.getSDKVersion().then((value) {
      setState(() {
        _sdkVersion = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: 5.0, top: 10.0, right: 5.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //VersionCode
            Text("版本号:$_sdkVersion"),

            //硬解开关
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("硬解开关"),
                Switch(
                    value: GlobalSettings.mEnableHardwareDecoder,
                    onChanged: (value) {
                      setState(() {
                        GlobalSettings.mEnableHardwareDecoder = value;
                      });
                    }),
              ],
            ),

            //HTTP 2 开关
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("HTTP 2"),
                Switch(
                    value: GlobalSettings.mEnableHTTP2,
                    onChanged: (value) {
                      setState(() {
                        GlobalSettings.mEnableHTTP2 = value;
                      });
                      FlutterAliplayer.setUseHttp2(value);
                    }),
              ],
            ),

            //httpdns 开关
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("HTTPDNS"),
                Switch(
                    value: GlobalSettings.mEnableHTTPDNS,
                    onChanged: (value) {
                      setState(() {
                        GlobalSettings.mEnableHTTPDNS = value;
                      });
                      FlutterAliplayer.enableHttpDns(value);
                    }),
              ],
            ),

            //播放器切换
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("播放器切换"), _buildChangePlayer()],
            ),

            SizedBox(
              height: 5.0,
            ),

            //黑名单,Android显示，iOS不显示
            Text(Platform.operatingSystemVersion),
            _blackListForAndroid(),

            SizedBox(
              height: 5.0,
            ),

            //本地缓存
            _localCache(),

            SizedBox(
              height: 10.0,
            ),

            //DSResolve
            _buildDNSResolve(),

            //Log
            Row(
              children: [
                Text("Log日志开关"),
                Switch(
                    value: GlobalSettings.mEnableAliPlayerLog,
                    onChanged: (value) {
                      FlutterAliplayer.enableConsoleLog(value);
                      FlutterAliplayer.enableConsoleLog(value);
                      GlobalSettings.mEnableAliPlayerLog = value;
                      setState(() {
                        GlobalSettings.mEnableAliPlayerLog = value;
                      });
                    })
              ],
            ),
            _buildLog(),
          ],
        ),
      ),
    );
  }

  //播放器切换
  Widget _buildChangePlayer() {
    return Column(
      children: _playerName.map((e) {
        return Container(
          height: 35.0,
          child: RadioListTile(
              dense: true,
              title: Text("$e"),
              value: e,
              groupValue: _currentPlayerName,
              onChanged: (value) {
                setState(() {
                  if (value == "Default") {
                    GlobalSettings.mPlayerName = "";
                  } else {
                    GlobalSettings.mPlayerName = value!;
                  }
                  _currentPlayerName = value!;
                });
              }),
        );
      }).toList(),
    );
  }

  //黑名单
  Widget _blackListForAndroid() {
    if (Platform.isAndroid) {
      return Row(
        children: [
          ElevatedButton(
            child: Text("HEVC黑名单"),
            onPressed: () {
              FlutterAliplayer.createDeviceInfo().then((value) {
                FlutterAliplayer.addBlackDevice(
                    FlutterAvpdef.BLACK_DEVICES_HEVC, value);
              });
            },
          ),
          SizedBox(
            width: 10.0,
          ),
          ElevatedButton(
            child: Text("H264黑名单"),
            onPressed: () {
              FlutterAliplayer.createDeviceInfo().then((value) {
                FlutterAliplayer.addBlackDevice(
                    FlutterAvpdef.BLACK_DEVICES_H264, value);
              });
            },
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  //本地缓存
  Widget _localCache() {
    return Column(
      children: [
        //是否开启缓存
        Row(
          children: [
            Text("是否开启本地缓存："),
            SizedBox(
              width: 5.0,
            ),
            Switch(
                value: GlobalSettings.mEnableLocalCache,
                onChanged: (value) {
                  setState(() {
                    GlobalSettings.mEnableLocalCache = value;
                  });
                }),
          ],
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          readOnly: true,
          controller: _mLocalCacheDirController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          decoration: InputDecoration(
            label: Text("缓存目录"),
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          controller: _mLocalCacheMaxLocalSizeController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: InputDecoration(
            label: Text("最大缓存大小(M)"),
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          controller: _mLocalCacheExpirationController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: InputDecoration(
            label: Text("缓存过期时间(天)"),
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          controller: _mLocalCacheMaxCacheCapacityController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: InputDecoration(
            label: Text("最大缓存容量(M)"),
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        TextField(
          controller: _mLocalCacheMinDiskCapacityController,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: InputDecoration(
            label: Text("磁盘最小空余容量(M)"),
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(
          height: 10.0,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              child: Text("恢复默认"),
              onPressed: () {
                _mLocalCacheMaxLocalSizeController.text =
                    LocalCacheDefaultValue.mDefaultMaxCacheSize;
                _mLocalCacheExpirationController.text =
                    LocalCacheDefaultValue.mDefaultExpiration;
                _mLocalCacheMaxCacheCapacityController.text =
                    LocalCacheDefaultValue.mDefaultMaxCapacity;
                _mLocalCacheMinDiskCapacityController.text =
                    LocalCacheDefaultValue.mDefaultMinDiskCapacity;
              },
            ),
            ElevatedButton(
              child: Text("应用配置"),
              onPressed: () {
                GlobalSettings.mCacheDir = _mLocalCacheDirController.text;
                GlobalSettings.mDocTypeForIOS = _saveDocTypeForIOS;
                GlobalSettings.mMaxCacheSize =
                    _mLocalCacheMaxLocalSizeController.text;
                GlobalSettings.mExpiration =
                    _mLocalCacheExpirationController.text;
                GlobalSettings.mMaxCapacity =
                    _mLocalCacheMaxCacheCapacityController.text;
                GlobalSettings.mMinDiskCapacity =
                    _mLocalCacheMinDiskCapacityController.text;

                FlutterAliplayer.enableLocalCache(
                    GlobalSettings.mEnableLocalCache,
                    GlobalSettings.mMaxCacheSize,
                    GlobalSettings.mCacheDir,
                    GlobalSettings.mDocTypeForIOS);

                FlutterAliplayer.setCacheFileClearConfig(
                    GlobalSettings.mExpiration,
                    GlobalSettings.mMaxCapacity,
                    GlobalSettings.mMinDiskCapacity);

                Fluttertoast.showToast(msg: "本地缓存配置成功");
              },
            ),
            ElevatedButton(
              child: Text("删除缓存"),
              onPressed: () {
                FlutterAliplayer.clearCaches();
              },
            ),
          ],
        )
      ],
    );
  }

  //DNS
  Widget _buildDNSResolve() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DNSResolve"),
        Text("输入格式:域名1:端口1,ip1;域名2:端口2,ip2;..."),
        SizedBox(
          height: 5.0,
        ),
        TextField(
          controller: _dnsTextEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        ElevatedButton(
          //TODO 设置无效
          child: Text("设置DNS"),
          onPressed: () {
            String dns = _dnsTextEditingController.text;
            print("dns = $dns");
          },
        ),
      ],
    );
  }

  //Log
  Widget _buildLog() {
    if (GlobalSettings.mEnableAliPlayerLog) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_NONE"),
                value: FlutterAvpdef.AF_LOG_LEVEL_NONE,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);

                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_FATAL"),
                value: FlutterAvpdef.AF_LOG_LEVEL_FATAL,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_ERROR"),
                value: FlutterAvpdef.AF_LOG_LEVEL_ERROR,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_WARNING"),
                value: FlutterAvpdef.AF_LOG_LEVEL_WARNING,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_INFO"),
                value: FlutterAvpdef.AF_LOG_LEVEL_INFO,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_DEBUG"),
                value: FlutterAvpdef.AF_LOG_LEVEL_DEBUG,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
          Container(
            height: 35.0,
            child: RadioListTile(
                dense: true,
                title: Text("AF_LOG_LEVEL_TRACE"),
                value: FlutterAvpdef.AF_LOG_LEVEL_TRACE,
                groupValue: _mLogLevel,
                onChanged: (value) {
                  FlutterAliplayer.setLogLevel(value as int);
                  setState(() {
                    _mLogLevel = value;
                    GlobalSettings.mLogLevel = value;
                  });
                }),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
