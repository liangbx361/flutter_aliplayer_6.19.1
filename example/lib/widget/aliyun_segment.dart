import 'package:flutter/material.dart';

typedef OnSelectAtIdx = void Function(int value);

class AliyunSegment extends StatelessWidget {
  final List<String> titles;
  final int selIdx;
  final OnSelectAtIdx onSelectAtIdx;

  const AliyunSegment(
      { required this.titles, this.selIdx = 0, required this.onSelectAtIdx})
      : super();

  @override
  Widget build(BuildContext context) {
    return Row(
        children: titles
            .asMap()
            .map((i, value) => MapEntry(
                i,
                Expanded(
                    child: i == selIdx
                        ? TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.black12,
                                shape: RoundedRectangleBorder(),
                                textStyle: TextStyle(
                                    color: Theme.of(context).canvasColor)),
                            onPressed: () => _onSelIdx(i),
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ))
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(),
                              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary)
                            ),
                            onPressed: () => _onSelIdx(i),
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )))))
            .values
            .toList());
  }

  _onSelIdx(int idx) {
    onSelectAtIdx(idx);
    }
}
