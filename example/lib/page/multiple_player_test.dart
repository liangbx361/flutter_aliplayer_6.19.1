import 'package:flutter/material.dart';
import 'package:flutter_aliplayer_example/page/multiple_player/multiple_player_between_page_a.dart';
import 'package:flutter_aliplayer_example/page/multiple_player/multiple_player_page.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';

class MultiplePlayerTest extends StatefulWidget {
  const MultiplePlayerTest({Key? key}) : super(key: key);

  @override
  _MultiplePlayerTestState createState() => _MultiplePlayerTestState();
}

class _MultiplePlayerTestState extends State<MultiplePlayerTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("多实例播放测试界面"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50.0,
            ),
            InkWell(
              child: Text("测试界面1"),
              onTap: (){
                CommomUtils.pushPage(context, MultiplePlayerPage());
              },
            ),
            SizedBox(
              height: 50.0,
            ),
            InkWell(
              child: Text("测试界面2"),
              onTap: (){
                CommomUtils.pushPage(context,MultiplePlayerBetweenPageA());
              },
            ),
          ],
        ),
      ),
    );
  }
}
