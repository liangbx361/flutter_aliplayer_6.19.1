import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LiveShiftPage extends StatefulWidget {
  const LiveShiftPage() : super();

  @override
  _LiveShiftPageState createState() => _LiveShiftPageState();
}

class _LiveShiftPageState extends State<LiveShiftPage> {
  var _url =
      "http://pull.livetest2.aliyunlive.com/demo_use/nochange.m3u8?lhs_start_human_s_8=20211118112200&aliyunols=on";
  var _timeLineUrl =
      "http://pull.livetest2.aliyunlive.com/openapi/timeline/query?aliyunols=on&app=demo_use&stream=nochange&format=ts";
  GlobalKey _sliderDividerContainerKey = GlobalKey();
  double _dividerHeight = 0.0;
  double _dividerWidth = 0.0;
  var _sliderDividerLeft = 0.0;
  var _sliderValue = 0.0;

  //提示内容
  String _tipsContent = '';
  var _flutterAliLiveShiftPlayer;
  var _sliderMax = 0.0;
  var mShiftStartTime = 0;
  var mShiftEndTime = -1;
  var timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox containerRenderBox = _sliderDividerContainerKey.currentContext
          ?.findRenderObject() as RenderBox;

      setState(() {
        _dividerHeight = containerRenderBox.size.height;
        _dividerWidth = containerRenderBox.size.width;
      });
    });

    _flutterAliLiveShiftPlayer =
        FlutterAliPlayerFactory.createAliLiveShiftPlayer(
            playerId: "aliLiveShiftPlayer");
    _initListener();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterAliLiveShiftPlayer.stop();
    _flutterAliLiveShiftPlayer.destroy();
  }

  void _initListener() {
    _flutterAliLiveShiftPlayer.setOnPrepared((playerId) {
      Fluttertoast.showToast(msg: "OnPrepared");
    });

    //时移时间更新监听事件
    _flutterAliLiveShiftPlayer.setOnTimeShiftUpdater(
        (currentTime, shiftStartTime, shiftEndTime, playerId) {
      mShiftEndTime = shiftEndTime;
      mShiftStartTime = shiftStartTime;
      var offsetTimeLen = shiftEndTime - shiftStartTime;
      _flutterAliLiveShiftPlayer.getCurrentLiveTime().then((value) {
        int currentLiveTime = value;
        if (mShiftEndTime - currentLiveTime < offsetTimeLen * 0.05) {
          mShiftEndTime = (currentLiveTime + offsetTimeLen * 0.1).round();
        }
        _startUpdateTimer();
      });
    });

    //时移seek完成通知
    _flutterAliLiveShiftPlayer.setOnSeekLiveCompletion((playTime, playerId) {
      Fluttertoast.showToast(msg: "OnSeekLiveCompletion");
    });

    _flutterAliLiveShiftPlayer.setOnLoadingStatusListener(
        loadingBegin: (playerId) {
      setState(() {
        _tipsContent = "loadingBegin";
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      setState(() {
        _tipsContent = "loading $percent";
      });
    }, loadingEnd: (playerId) {
      setState(() {
        _tipsContent = "loadingEnd";
      });
    });

    _flutterAliLiveShiftPlayer
        .setOnError((errorCode, errorExtra, errorMsg, playerId) {
      setState(() {
        _tipsContent = "errorCode:$errorCode -- errorMsg:$errorMsg";
      });
    });
  }

  void _startUpdateTimer() {
    _flutterAliLiveShiftPlayer.getCurrentTime().then((value) {
      setState(() {
        _updateRange();
        _sliderValue = value - mShiftStartTime * 1.0;
        if (_sliderValue > _sliderMax) {
          _sliderValue = _sliderMax;
        }
      });
      _flutterAliLiveShiftPlayer.getCurrentLiveTime().then((value) {
        var secondProgress = value - mShiftStartTime;
        setState(() {
          _sliderDividerLeft =
              secondProgress * 1.0 / _sliderMax * _dividerWidth;
        });
      });
      if (timer != null) {
        timer.cancel();
      }
      timer = new Timer.periodic(Duration(seconds: 1), (_) {
        _startUpdateTimer();
      });
    });
  }

  void _updateRange() {
    _sliderMax = max(mShiftStartTime * 1.0, mShiftEndTime * 1.0);
  }

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
        SizedBox(width: 1, height: 30),
        _buildSlider(),
        SizedBox(width: 1, height: 30),
        _buildPlayerOperator(),
        SizedBox(width: 1, height: 30),
        _buildTipsView()
      ]),
    );
  }

  //进度条
  Widget _buildSlider() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                  key: _sliderDividerContainerKey,
                  min: 0,
                  max: _sliderMax,
                  value: _sliderValue,
                  onChanged: (value) {
                    _flutterAliLiveShiftPlayer
                        .seekToLiveTime((value + mShiftStartTime).round());
                    setState(() {
                      _sliderValue = value;
                    });
                  })),
          Positioned(
            left: _sliderDividerLeft - 5,
            child: SizedBox(
              width: 5,
              height: _dividerHeight / 2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerOperator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
            child: TextButton(
                child: Text("准备"),
                onPressed: () {
                  _flutterAliLiveShiftPlayer.prepare();
                })),
        InkWell(
            child: TextButton(
                child: Text("播放"),
                onPressed: () {
                  _flutterAliLiveShiftPlayer.play();
                })),
        InkWell(
            child: Text("停止"),
            onTap: () {
              _flutterAliLiveShiftPlayer.stop();
            })
      ],
    );
  }

  Widget _buildTipsView() {
    if (_tipsContent.isNotEmpty) {
      return Text(
        _tipsContent,
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
    } else {
      return Container();
    }
  }

  void onViewPlayerCreated(int viewId) {
    this._flutterAliLiveShiftPlayer.setPlayerView(viewId);
    int time = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    var timeLineUrl =
        "$_timeLineUrl&lhs_start_unix_s_0=${time - 5 * 60}&lhs_end_unix_s_0=${time + 5 * 60}";
    _flutterAliLiveShiftPlayer.setDataSource(timeLineUrl, _url);
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx + 10;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 20;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
