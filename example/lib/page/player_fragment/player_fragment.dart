import 'package:flutter/material.dart';
import 'package:flutter_aliplayer_example/model/video_model.dart';

class PlayerFragment extends StatefulWidget {
  final VideoModel model;

  const PlayerFragment({required this.model}) : super();
  @override
  _PlayerFragmentState createState() => _PlayerFragmentState();
}

class _PlayerFragmentState extends State<PlayerFragment> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          widget.model.coverUrl,
          fit: BoxFit.fitWidth,
        )
      ],
    );
  }
}
