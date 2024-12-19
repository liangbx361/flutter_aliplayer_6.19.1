import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/definition_model.dart';
import 'package:flutter_aliplayer_example/page/player_page.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';
import 'package:flutter_aliplayer_example/util/network_utils.dart';
import 'package:flutter_aliplayer_example/widget/aliyun_regin_dropdown.dart';

class StsPage extends StatefulWidget {
  @override
  _StsHomePageState createState() => _StsHomePageState();
}

class _StsHomePageState extends State<StsPage> {
  TextEditingController _vidController =
      TextEditingController.fromValue(TextEditingValue(
    text: DataSourceRelated.DEFAULT_VID,
  ));
  TextEditingController _accessKeyIdController = TextEditingController();
  TextEditingController _accessKeySecretController = TextEditingController();
  TextEditingController _previewController = TextEditingController();
  TextEditingController _securityTokenController = TextEditingController();
  String _region = DataSourceRelated.DEFAULT_REGION;
  // late List<DefinitionModel> _definitionList;
  var _definitionList;

  ///设置点播服务器返回的码率清晰度类型。
  int _selectDefinition = -1;
  List<String> _selectedDefinition =[];

  bool _inPushing = false;

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
        title: Text("STS 播放"),
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
            //试看时间(s)
            TextField(
              controller: _previewController,
              maxLines: 1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "试看时间(s)",
              ),
            ),
            //SecurityToken
            TextField(
              controller: _securityTokenController,
              decoration: InputDecoration(
                labelText: "SecurityToken",
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
                  child: Text("STS播放"),
                  onPressed: () {
                    if (_inPushing == true) {
                      return;
                    }
                    _inPushing = true;
                    List<String> _definitionList = [];
                    if (_selectDefinition == 2) {
                      _definitionList.add(FlutterAvpdef.AUTO);
                    } else if (_selectDefinition == 1) {
                      _definitionList.addAll(_selectedDefinition);
                    } else {
                      _definitionList.clear();
                    }
                    NetWorkUtils.instance.getHttp(HttpConstant.GET_STS,
                        successCallback: (data) {
                      _accessKeyIdController.text = data["accessKeyId"];
                      _accessKeySecretController.text = data["accessKeySecret"];
                      _securityTokenController.text = data["securityToken"];
                      var map = {
                        DataSourceRelated.VID_KEY: _vidController.text,
                        DataSourceRelated.ACCESSKEYID_KEY:
                            _accessKeyIdController.text,
                        DataSourceRelated.ACCESSKEYSECRET_KEY:
                            _accessKeySecretController.text,
                        DataSourceRelated.SECURITYTOKEN_KEY:
                            _securityTokenController.text,
                        DataSourceRelated.REGION_KEY: _region,
                        DataSourceRelated.PREVIEWTIME_KEY:
                            _previewController.text,
                        DataSourceRelated.DEFINITION_LIST: _definitionList
                      };
                      CommomUtils.pushPage(
                          context,
                          PlayerPage(
                            playMode: ModeType.STS,
                            dataSourceMap: map,
                          ));
                      _inPushing = false;
                    }, errorCallback: (error) {
                      print("error");
                      _inPushing = false;
                    }, params: {});
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
                    _accessKeyIdController.clear();
                    _accessKeySecretController.clear();
                    _securityTokenController.clear();
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
