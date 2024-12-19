import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/widget/aliyun_segment.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef OnEnablePlayBackChanged = Function(bool mEnablePlayBack);

class OptionsFragment extends StatefulWidget {
  final FlutterAliplayer fAliplayer;
  var playBackChanged;
  var _optionsFragmentState;

  OptionsFragment(this.fAliplayer);

  ///硬解失败切换到软解
  void setOnEnablePlayBackChanged(OnEnablePlayBackChanged enable) {
    this.playBackChanged = enable;
  }

  void switchHardwareDecoder() {
    _optionsFragmentState.switchHardwareDecoder();
  }

  @override
  _OptionsFragmentState createState() =>
      _optionsFragmentState = _OptionsFragmentState();
}

class _OptionsFragmentState extends State<OptionsFragment> {
  bool mAutoPlay = false;
  bool mMute = false;
  bool mLoop = false;
  bool mFastStart = false;
  bool mEnableHardwareDecoder = false;
  bool mEnablePlayBack = false;
  int mScaleGroupValue = 0;
  int mAlphaGroupValue = 0;
  int mMirrorGroupValue = 0;
  int mRotateGroupValue = FlutterAvpdef.AVP_ROTATE_0;
  int mSpeedGroupValueIndex = 0;
  double mSpeedGroupValue = 1;
  double _volume = 100;
  TextEditingController _bgColorController = TextEditingController();
  TextEditingController _setMaxAccurateSeekController = TextEditingController();
  TextEditingController _setDefaultBandWidthController =
      TextEditingController();

  _loadInitData() async {
    mLoop = await widget.fAliplayer.isLoop();
    mAutoPlay = await widget.fAliplayer.isAutoPlay();
    mMute = await widget.fAliplayer.isMuted();
    mEnableHardwareDecoder = GlobalSettings.mEnableHardwareDecoder;
    mScaleGroupValue = await widget.fAliplayer.getScalingMode();
    mMirrorGroupValue = await widget.fAliplayer.getMirrorMode();
    int rotateMode = await widget.fAliplayer.getRotateMode();
    mRotateGroupValue = (rotateMode / 90).round();
    double speedMode = await widget.fAliplayer.getRate();
    if (speedMode == 0) {
      mSpeedGroupValueIndex = 0;
    } else if (speedMode == 0.5) {
      mSpeedGroupValueIndex = 1;
    } else if (speedMode == 1.5) {
      mSpeedGroupValueIndex = 2;
    } else if (speedMode == 2.0) {
      mSpeedGroupValueIndex = 3;
    }
    double volume = await widget.fAliplayer.getVolume();
    _volume = volume * 100;
    setState(() {});
  }

  ///硬解失败切换到软解
  void switchHardwareDecoder() {
    mEnableHardwareDecoder = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  @override
  void dispose() {
    super.dispose();
    GlobalSettings.mEnableAccurateSeek = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              _buildSwitch(),
              _buildVolume(),
              _buildAlpha(),
              _buildScale(),
              _buildMirror(),
              _buildRotate(),
              _buildSpeed(),
              _buildAccurateSeek(),
              _buildDefaultBandWidth(),
              _buildBgColor(),
              _buildPlayBack(),
            ],
          ),
        ),
      ),
    );
  }

  /// switch for : autoplay、mute、loop...
  Wrap _buildSwitch() {
    return Wrap(
      children: [
        Column(
          children: [
            CupertinoSwitch(
              value: mAutoPlay,
              onChanged: (value) {
                setState(() {
                  mAutoPlay = value;
                });
                widget.fAliplayer.setAutoPlay(mAutoPlay);
              },
            ),
            Text("自动播放"),
          ],
        ),
        SizedBox(width: 10.0),
        Column(
          children: [
            CupertinoSwitch(
              value: mFastStart,
              onChanged: (value) {
                setState(() {
                  mFastStart = value;
                });
                widget.fAliplayer.setFastStart(mFastStart);
              },
            ),
            Text("快速播放"),
          ],
        ),
        SizedBox(width: 10.0),
        Column(
          children: [
            CupertinoSwitch(
              value: mMute,
              onChanged: (value) {
                setState(() {
                  mMute = value;
                });
                widget.fAliplayer.setMuted(mMute);
              },
            ),
            Text("静音"),
          ],
        ),
        SizedBox(width: 10.0),
        Column(
          children: [
            CupertinoSwitch(
              value: mLoop,
              onChanged: (value) {
                setState(() {
                  mLoop = !mLoop;
                });
                widget.fAliplayer.setLoop(mLoop);
              },
            ),
            Text("循环"),
          ],
        ),
        SizedBox(width: 10.0),
        Column(
          children: [
            CupertinoSwitch(
              value: mEnableHardwareDecoder,
              onChanged: (value) {
                setState(() {
                  GlobalSettings.mEnableHardwareDecoder = !mEnableHardwareDecoder;
                });
              },
            ),
            Text("硬解"),
          ],
        ),
        SizedBox(width: 10.0),
        Column(
          children: [
            CupertinoSwitch(
              value: GlobalSettings.mEnableAccurateSeek,
              onChanged: (value) {
                setState(() {
                  GlobalSettings.mEnableAccurateSeek = value;
                });
              },
            ),
            Text("精准seek"),
          ],
        ),
        _buildPipSwitch(),
      ],
    );
  }

  Column _buildPipSwitch() {
    return Column(
      children: [
        CupertinoSwitch(
          value: GlobalSettings.mEnabletPictureInPicture,
          onChanged: (value) {
            setState(() {
              GlobalSettings.mEnabletPictureInPicture = value;
            });
            if (Platform.isIOS) {
              widget.fAliplayer.setPictureInPictureEnableForIOS(value);
              widget.fAliplayer.setPictureInPictureShowMode(FlutterAvpdef.AVP_SHOW_MODE_DEFAULT);
            }
          },
        ),
        Text("画中画"),
      ],
    );
  }

  /// 音量
  Row _buildVolume() {
    return Row(
      children: [
        SizedBox(
          width: 10.0,
        ),
        Text("音量"),
        Expanded(
          child: Slider(
            value: _volume,
            max: 200,
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
              widget.fAliplayer.setVolume(_volume / 100);
            },
          ),
        ),
      ],
    );
  }

  /// Alpha渲染模式
  Row _buildAlpha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('渲染模式'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AliyunSegment(
              titles: ['右侧', '左侧', '上侧', '下侧'],
              selIdx: mAlphaGroupValue,
              onSelectAtIdx: (value) {
                mAlphaGroupValue = value;
                widget.fAliplayer.setAlphaRenderMode(mAlphaGroupValue);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 缩放模式
  Row _buildScale() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('缩放模式'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AliyunSegment(
              titles: ['比例填充', '比例全屏', '拉伸全屏'],
              selIdx: mScaleGroupValue,
              onSelectAtIdx: (value) {
                mScaleGroupValue = value;
                widget.fAliplayer.setScalingMode(mScaleGroupValue);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 镜像模式
  Row _buildMirror() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('镜像模式'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AliyunSegment(
              titles: ['无镜像', '水平镜像', '垂直镜像'],
              selIdx: mMirrorGroupValue,
              onSelectAtIdx: (value) {
                mMirrorGroupValue = value;
                widget.fAliplayer.setMirrorMode(mMirrorGroupValue);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 旋转模式
  Container _buildRotate() {
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text('旋转模式'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AliyunSegment(
              titles: ['0°', '90°', '180°', "270°"],
              selIdx: mRotateGroupValue,
              onSelectAtIdx: (value) {
                mRotateGroupValue = value;
                widget.fAliplayer.setRotateMode(mRotateGroupValue * 90);
                setState(() {});
              },
            ),
          ),
        ),
      ]),
    );
  }

  /// 倍速播放
  Row _buildSpeed() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('倍速播放'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AliyunSegment(
              titles: ['正常', '0.5倍速', '1.5倍速', "2.0倍速"],
              selIdx: mSpeedGroupValueIndex,
              onSelectAtIdx: (value) {
                mSpeedGroupValueIndex = value;
                switch (value) {
                  case 0:
                    mSpeedGroupValue = 1.0;
                    break;
                  case 1:
                    mSpeedGroupValue = 0.5;
                    break;
                  case 2:
                    mSpeedGroupValue = 1.5;
                    break;
                  case 3:
                    mSpeedGroupValue = 2.0;
                    break;
                  default:
                }
                widget.fAliplayer.setRate(mSpeedGroupValue);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 背景色
  Row _buildBgColor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 10.0,
        ),
        Text("背景色"),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: TextField(
            maxLines: 1,
            maxLength: 20,
            controller: _bgColorController,
          ),
        ),
        SizedBox(
          width: 30.0,
        ),
        InkWell(
          onTap: () {
            String colorStr = _bgColorController.text;
            if (colorStr.startsWith('#')) {
              colorStr = colorStr.replaceRange(0, 1, '0xff');
            }
            int? color = int.tryParse(colorStr);
            if (color != null) {
              widget.fAliplayer.setVideoBackgroundColor(color);
            } else {
              Fluttertoast.showToast(msg: '请输入正确的色值');
            }
          },
          child: Text(
            "确定",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  ///精准 seek 最大间隔
  Row _buildAccurateSeek() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 10.0,
        ),
        SizedBox(
          child: Text("精准seek间隔(ms)"),
          width: 50.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextField(
            maxLines: 1,
            maxLength: 10,
            controller: _setMaxAccurateSeekController,
          ),
        ),
        SizedBox(
          width: 30.0,
        ),
        InkWell(
          onTap: () {
            String time = _setMaxAccurateSeekController.text;
            widget.fAliplayer.setMaxAccurateSeekDelta(int.parse(time));
          },
          child: Text(
            "确定",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  Row _buildDefaultBandWidth() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 10.0,
        ),
        SizedBox(
          child: Text("多码率默认播放码率"),
          width: 50.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextField(
            maxLines: 1,
            maxLength: 10,
            controller: _setDefaultBandWidthController,
          ),
        ),
        SizedBox(
          width: 30.0,
        ),
        InkWell(
          onTap: () {
            String time = _setDefaultBandWidthController.text;
            widget.fAliplayer.setDefaultBandWidth(int.parse(time));
          },
          child: Text(
            "确定",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  /// 后台播放
  Row _buildPlayBack() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            CupertinoSwitch(
              value: mEnablePlayBack,
              onChanged: (value) {
                widget.playBackChanged(value);
                setState(
                  () {
                    mEnablePlayBack = value;
                  },
                );
              },
            ),
            Text("后台播放"),
          ],
        ),
        InkWell(
          child: Text(
            "媒体信息",
            style: TextStyle(color: Colors.blue),
          ),
          onTap: () {
            widget.fAliplayer.getMediaInfo().then(
              (value) {
                Fluttertoast.showToast(msg: value.toString());
              },
            );
          },
        ),
      ],
    );
  }
}
