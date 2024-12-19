import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';

class FilterFragment extends StatefulWidget {
  final FlutterAliplayer fAliplayer;

  FilterFragment(this.fAliplayer);

  @override
  _FilterFragmentState createState() => _FilterFragmentState();
}

class _FilterFragmentState extends State<FilterFragment> {
  bool _mEnableSharp = false;
  bool _mEnableSR = false;
  double _mStrengthValue = 0.00;

  @override
  void initState() {
    super.initState();
    List<AVPFilterInfo> avpFilterList =[];
    //add sharp
    AVPFilterInfo shapeFilterInfo = new AVPFilterInfo();
    List<String> shapeListOptions =[];
    shapeListOptions.add("strength");
    shapeFilterInfo.target = "sharp";
    shapeFilterInfo.options = shapeListOptions;

    //add sr
    AVPFilterInfo srFilterInfo = new AVPFilterInfo();
    srFilterInfo.target = "sr";

    avpFilterList.add(shapeFilterInfo);
    avpFilterList.add(srFilterInfo);

    var avpFilterJson = jsonEncode(avpFilterList);
    widget.fAliplayer.setFilterConfig(avpFilterJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          margin:
              EdgeInsets.only(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0),
          child: Column(
            children: [
              SizedBox(width: 1, height: 20),
              _buildSharp(),
              _buildsr()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharp() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("sharp"),
            CupertinoSwitch(
              value: _mEnableSharp,
              onChanged: (value) {
                setState(() {
                  _mEnableSharp = value;
                });
                widget.fAliplayer.setFilterInvalid("sharp", (!_mEnableSharp).toString());
              },
            )
          ],
        ),
        _buildSharpSlider()
      ],
    );
  }

  Widget _buildSharpSlider() {
    if (_mEnableSharp) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("strength"),
          Slider(
              value: _mStrengthValue,
              min: 0.00,
              max: 1.00,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _mStrengthValue = value;
                });
                var map = {"strength":_mStrengthValue};
                widget.fAliplayer.updateFilterConfig("sharp", map);
              }),
          SizedBox(width: 30, height: 20, child: Text("$_mStrengthValue"))
        ],
      );
    } else {
      return SizedBox(width: 1, height: 1);
    }
  }

  Widget _buildsr() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("sr"),
        CupertinoSwitch(
          value: _mEnableSR,
          onChanged: (value) {
            setState(() {
              _mEnableSR = value;
            });
            widget.fAliplayer.setFilterInvalid("sr", (!_mEnableSR).toString());
          },
        )
      ],
    );
  }
}
