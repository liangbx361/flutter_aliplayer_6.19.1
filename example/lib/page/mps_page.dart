import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';
import 'package:flutter_aliplayer_example/config.dart';
import 'package:flutter_aliplayer_example/model/definition_model.dart';
import 'package:flutter_aliplayer_example/page/player_page.dart';
import 'package:flutter_aliplayer_example/util/common_utils.dart';
import 'package:flutter_aliplayer_example/util/network_utils.dart';
import 'package:flutter_aliplayer_example/widget/aliyun_regin_dropdown.dart';

class MpsPage extends StatefulWidget {
  @override
  _MpsPagePageState createState() => _MpsPagePageState();
}

class _MpsPagePageState extends State<MpsPage> {
  var _netWorkUtils;
  TextEditingController _vidController = TextEditingController();
  TextEditingController _accessKeyIdController = TextEditingController();
  TextEditingController _accessKeySecretController = TextEditingController();
  TextEditingController _playDomainController = TextEditingController();
  TextEditingController _securityTokenController = TextEditingController();
  TextEditingController _authInfoController = TextEditingController();
  TextEditingController _hlsUriTokenController = TextEditingController();
  String _region = DataSourceRelated.DEFAULT_REGION;

  var _definitionList;

  ///设置点播服务器返回的码率清晰度类型。
  int _selectDefinition = -1;
  List<String> _selectedDefinition = <String>[];

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
        title: Text("MPS 播放"),
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
                currentHint: _region,
                onRegionChanged: (region) => {_region = region},
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
            //PlayDomain
            TextField(
              controller: _playDomainController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "PlayDomain",
              ),
            ),
            //AuthInfo
            TextField(
              controller: _authInfoController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "AuthInfo",
              ),
            ),
            //HlsUriToken
            TextField(
              controller: _hlsUriTokenController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "HlsUriToken",
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
                        if (value as bool) {
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
                  child: Text("MPS播放"),
                  onPressed: () {
                    List<String> _definitionList = <String>[];
                    if (_selectDefinition == 2) {
                      _definitionList.add(FlutterAvpdef.AUTO);
                    } else if (_selectDefinition == 1) {
                      _definitionList.addAll(_selectedDefinition);
                    } else {
                      _definitionList.clear();
                    }
                    NetWorkUtils.instance.getHttp(HttpConstant.GET_MPS,
                        successCallback: (data) {
                          _region = data["RegionId"];
                          _vidController.text = data["MediaId"];
                          _authInfoController.text = data["authInfo"];
                          _hlsUriTokenController.text = data["HlsUriToken"];
                          var _akInfo = data["AkInfo"];
                          if (_akInfo != null) {
                            _accessKeyIdController.text = _akInfo["AccessKeyId"];
                            _accessKeySecretController.text =
                            _akInfo["AccessKeySecret"];
                            _securityTokenController.text =
                            _akInfo["SecurityToken"];
                          }
                          var map = {
                            DataSourceRelated.REGION_KEY: _region,
                            DataSourceRelated.VID_KEY: _vidController.text,
                            DataSourceRelated.ACCESSKEYID_KEY:
                            _accessKeyIdController.text,
                            DataSourceRelated.ACCESSKEYSECRET_KEY:
                            _accessKeySecretController.text,
                            DataSourceRelated.PLAYDOMAIN_KEY:
                            _playDomainController.text,
                            DataSourceRelated.AUTHINFO_KEY:
                            _authInfoController.text,
                            DataSourceRelated.HLSURITOKEN_KEY:
                            _hlsUriTokenController.text,
                            DataSourceRelated.SECURITYTOKEN_KEY:
                            _securityTokenController.text,
                            DataSourceRelated.DEFINITION_LIST: _definitionList
                          };
                          CommomUtils.pushPage(
                              context,
                              PlayerPage(
                                playMode: ModeType.MPS,
                                dataSourceMap: map,
                              ));
                        }, errorCallback: (error) {}, );
                  },
                ),
                Expanded(
                  child: SizedBox(),
                ),
                ElevatedButton(
                  child: Text("清除"),
                  onPressed: () {
                    _vidController.clear();
                    _accessKeyIdController.clear();
                    _accessKeySecretController.clear();
                    _playDomainController.clear();
                    _authInfoController.clear();
                    _hlsUriTokenController.clear();
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
            _selectDefinition = value as int
            ;
          });
        },
      ),
    );
  }
}
