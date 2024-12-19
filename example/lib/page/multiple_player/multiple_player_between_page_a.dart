import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'multiple_player_between_page_b.dart';

class MultiplePlayerBetweenPageA extends StatefulWidget {
  const MultiplePlayerBetweenPageA() : super();

  @override
  _MultiplePlayerBetweenPageAState createState() =>
      _MultiplePlayerBetweenPageAState();
}

class _MultiplePlayerBetweenPageAState
    extends State<MultiplePlayerBetweenPageA> {
  var player;

  @override
  void initState() {
    super.initState();
    player = FlutterAliPlayerFactory.createAliPlayer(playerId: "playerA");
    player.setAutoPlay(true);
    player.setUrl(DataSourceRelated.DEFAULT_URL);

    player.setOnPrepared((playerId) {
      Fluttertoast.showToast(msg: "prepared : ${player.playerId}");
      print("prepared : ${player.playerId}");
      player
          .getPlayerName()
          .then((value) => print("getPlayerName==${value}"));
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
    player.destroy();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = width * 9 / 16;
    AliPlayerView aliPlayerView = AliPlayerView(
        onCreated: (int viewId) {
          player.setPlayerView(viewId);
          player.prepare();
        },
        x: 0,
        y: 0,
        width: width,
        height: height);
    return Scaffold(
      appBar: AppBar(
        title: Text("多实例播放测试界面A"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: width,
            height: height,
            child: aliPlayerView,
          ),
          SizedBox(
            width: 0,
            height: 50,
          ),
          InkWell(
            child: Text("准备"),
            onTap: () {
              player.prepare();
            },
          ),
          SizedBox(
            width: 0,
            height: 30,
          ),
          InkWell(
            child: Text("播放"),
            onTap: () {
              player.play();
            },
          ),
          SizedBox(
            width: 0,
            height: 30,
          ),
          InkWell(
            child: Text("暂停"),
            onTap: () {
              player.pause();
            },
          ),
          SizedBox(
            width: 0,
            height: 30,
          ),
          InkWell(
            child: Text("Open Page B"),
            onTap: () {
              CommomUtils.pushPage(context, MultiplePlayerBetweenPageB());
            },
          )
        ],
      ),
    );
  }
}
