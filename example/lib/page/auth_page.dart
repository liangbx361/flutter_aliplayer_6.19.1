import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/definition_model.dart';
import 'package:flutter_aliplayer_example/page/player_page.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';
import 'package:flutter_aliplayer_example/util/network_utils.dart';
import 'package:flutter_aliplayer_example/widget/aliyun_regin_dropdown.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController _vidController = TextEditingController.fromValue(
      TextEditingValue(text: DataSourceRelated.DEFAULT_VID));
  TextEditingController _previewController = TextEditingController();
  TextEditingController _playAuthController = TextEditingController();
  String _region = DataSourceRelated.DEFAULT_REGION;
  var _definitionList;

  ///设置点播服务器返回的码率清晰度类型。
  int _selectDefinition = -1;
  List<String> _selectedDefinition = [];

  var _inPushing;

  @override
  void initState() {
    super.initState();
    _definitionList = [
      DefinitionModel(FlutterAvpdef.FD),
      DefinitionModel(FlutterAvpdef.LD),
      DefinitionModel(FlutterAvpdef.SD),
      DefinitionModel(FlutterAvpdef.HD),
      DefinitionModel(FlutterAvpdef.OD),
      DefinitionModel(FlutterAvpdef.K2),
      DefinitionModel(FlutterAvpdef.K4),
      DefinitionModel(FlutterAvpdef.SQ),
      DefinitionModel(FlutterAvpdef.HQ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AUTH 播放"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15.0, top: 5.0, right: 15.0, bottom: 0),
        child: Column(
          children: [
            //Region
            Container(
              width: double.infinity,
              child: ReginDropDownButton(
                currentHint: DataSourceRelated.DEFAULT_REGION,
                onRegionChanged: (region) => _region = region,
              ),
            ),
            //vid
            TextField(
              controller: _vidController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "vid",
              ),
            ),
            //试看时间(s)
            TextField(
              controller: _previewController,
              maxLines: 1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "试看时间(s)",
              ),
            ),
            //PlayAuth
            TextField(
              controller: _playAuthController,
              decoration: InputDecoration(
                labelText: "PlayAuth",
              ),
            ),

            Row(
              children: [
                _radioButton("Definition", 1),
                _radioButton("AUTO", 2),
              ],
            ),

            _selectDefinition == 1
                ? Expanded(
                    child: GridView.builder(
                        itemCount: _definitionList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2.0,
                            crossAxisSpacing: 2.0,
                            childAspectRatio: 3),
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                            value: _definitionList[index].isChecked,
                            dense: true,
                            title: Text(_definitionList[index].title),
                            onChanged: (value) {
                              if (value!) {
                                _selectedDefinition
                                    .add(_definitionList[index].title);
                              } else {
                                _selectedDefinition
                                    .remove(_definitionList[index].title);
                              }
                              setState(() {
                                _definitionList[index].isChecked = value;
                              });
                            },
                          );
                        }),
                  )
                : Container(),

            SizedBox(
              height: 30.0,
            ),

            Row(
              children: [
                ElevatedButton(
                  child: Text("AUTH播放"),
                  onPressed: () {
                    if (_inPushing == true) {
                      return;
                    }
                    _inPushing = true;
                    List<String> _definitionList =[];
                    if (_selectDefinition == 2) {
                      _definitionList.add(FlutterAvpdef.AUTO);
                    } else if (_selectDefinition == 1) {
                      _definitionList.addAll(_selectedDefinition);
                    } else {
                      _definitionList.clear();
                    }
                    var params = {"videoId": _vidController.text};
                    NetWorkUtils.instance.getHttp(HttpConstant.GET_AUTH,
                        params: params, successCallback: (data) {
                      _playAuthController.text = data["playAuth"];
                      var map = {
                        DataSourceRelated.VID_KEY: _vidController.text,
                        DataSourceRelated.REGION_KEY: _region,
                        DataSourceRelated.PLAYAUTH_KEY:
                            _playAuthController.text,
                        DataSourceRelated.PREVIEWTIME_KEY:
                            _previewController.text,
                        DataSourceRelated.DEFINITION_LIST: _definitionList
                      };
                      CommomUtils.pushPage(
                          context,
                          PlayerPage(
                            playMode: ModeType.AUTH,
                            dataSourceMap: map,
                          ));
                      _inPushing = false;
                    }, errorCallback: (error) {
                      _inPushing = false;
                    });
                  },
                ),
                Expanded(
                  child: SizedBox(),
                ),
                ElevatedButton(
                  child: Text("清除"),
                  onPressed: () {
                    _vidController.clear();
                    _previewController.clear();
                    _playAuthController.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _radioButton(String title, int value) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 160, height: 50),
      alignment: Alignment.center,
      child: RadioListTile(
        value: value,
        groupValue: _selectDefinition,
        title: Text(title),
        onChanged: (value) {
          setState(() {
            _selectDefinition = value!;
          });
        },
      ),
    );
  }
}
