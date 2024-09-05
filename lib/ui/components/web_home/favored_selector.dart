import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:flutter/material.dart';

class FavoredSelector extends StatelessWidget {
  const FavoredSelector({
    super.key,
    required this.favoredList,
    required this.onTap,
  });

  final List<Favored> favoredList;
  final Function(Favored favored) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: favoredList.length,
      itemBuilder: (_, index) {
        return ListTile(
          onTap: () => onTap(favoredList[index]),
          title: Text(favoredList[index].title),
        );
      },
    );
  }
}
