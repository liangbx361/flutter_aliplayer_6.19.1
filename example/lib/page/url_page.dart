import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_medialoader.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/page/player_page.dart';
import 'package:flutter_aliplayer_example/page/qr_code_page.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';

class UrlPage extends StatefulWidget {
  @override
  _UrlPageState createState() => _UrlPageState();
}

class _UrlPageState extends State<UrlPage> {
  TextEditingController urlSourceController =
  new TextEditingController.fromValue(TextEditingValue(
    text: DataSourceRelated.DEFAULT_URL,
  ));
  String _qrcode_result = DataSourceRelated.DEFAULT_URL;

  bool _inPushing = false;
  FlutterAliPlayerMediaLoader? fAliPlayerMediaLoader;

  Future<void> getQrcodeState() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRViewPage(),
      ),
    );

    if (result != null) {
      _qrcode_result=result;
      setState(() {
        urlSourceController.text=_qrcode_result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fAliPlayerMediaLoader = FlutterAliPlayerMediaLoader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("URL 播放"),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.crop_free), onPressed: () => getQrcodeState())
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: urlSourceController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: "url",
            ),
            keyboardType: TextInputType.multiline,
          ),
          ElevatedButton(
            child: Text("开始播放"),
            onPressed: () {
              if (_inPushing == true) {
                return;
              }
              _inPushing = true;
              var map = {DataSourceRelated.URL_KEY: urlSourceController.text};
              CommomUtils.pushPage(context,
                  PlayerPage(playMode: ModeType.URL, dataSourceMap: map));
              _inPushing = false;
            },
          ),
          SizedBox(height: 50.0),
          _buildMediaLoader()
        ],
      ),
    );
  }

  Widget _buildMediaLoader() {
    return Column(
      children: [
        Text("预加载",style: TextStyle(fontSize: 20.0),),
        SizedBox(height: 5.0,),
        Text("使用预加载前，需要在 Settings 页面打开本地缓存",style: TextStyle(fontSize: 12.0),),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 1.0),
            InkWell(child: Text("load",style: TextStyle(color: Colors.blue)), onTap: () {
              fAliPlayerMediaLoader?.load(urlSourceController.text, "${5*1000}");
                        }),
            InkWell(child: Text("pause",style: TextStyle(color: Colors.blue)), onTap: () {
              fAliPlayerMediaLoader?.pause(urlSourceController.text);
                        }),
            InkWell(child: Text("resume",style: TextStyle(color: Colors.blue)), onTap: () {
              fAliPlayerMediaLoader?.resume(urlSourceController.text);
                        }),
            InkWell(child: Text("cancel",style: TextStyle(color: Colors.blue)), onTap: () {
              fAliPlayerMediaLoader?.cancel(urlSourceController.text);
                        }),
            SizedBox(width: 1.0)
          ],
        )
      ],
    );
  }
}