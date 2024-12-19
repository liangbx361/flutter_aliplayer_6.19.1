import 'package:flutter/cupertino.dart';

class MarqueeView extends StatefulWidget {
  final Duration pauseDuration;

  ///滚动速度，单位s
  final double scrollSpeed;
  final Widget child;

  const MarqueeView(
      { Key? key,
      this.pauseDuration = const Duration(milliseconds: 100),
      this.scrollSpeed = 100.0,
      required this.child})
      : super(key: key);

  @override
  _MarqueeViewState createState() => _MarqueeViewState();
}

class _MarqueeViewState extends State<MarqueeView>
    with SingleTickerProviderStateMixin {
  bool _validFlag = true;
  double _boxWidth = 0;
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _validFlag = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scroll();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _boxWidth = constraints.maxWidth;
        return SingleChildScrollView(
          // 禁止手动滑动。
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _boxWidth),
            child: widget.child,
          ),
        );
      },
    );
  }

  void scroll() async {
    while (_validFlag) {
      await Future.delayed(widget.pauseDuration);
      if (_boxWidth <= 0) {
        continue;
      }
      _controller.jumpTo(0);
      await _controller.animateTo(_controller.position.maxScrollExtent,
          duration: Duration(
            seconds: (_controller.position.maxScrollExtent / widget.scrollSpeed).floor(),
          ),
          curve: Curves.easeInToLinear);
    }
  }
}
