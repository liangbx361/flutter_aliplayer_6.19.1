import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MultiplePlayerBetweenPageB extends StatefulWidget {
  const MultiplePlayerBetweenPageB() : super();

  @override
  _MultiplePlayerBetweenPageBState createState() =>
      _MultiplePlayerBetweenPageBState();
}

class _MultiplePlayerBetweenPageBState
    extends State<MultiplePlayerBetweenPageB> {
  var player;

  @override
  void initState() {
    super.initState();
    player = FlutterAliPlayerFactory.createAliPlayer(playerId: "playerB");
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
        title: Text("多实例播放测试界面B"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: width,
            height: height,
            child: aliPlayerView,
          ),
        ],
      ),
    );
  }
}
