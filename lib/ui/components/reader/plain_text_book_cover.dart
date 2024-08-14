import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class PlainTextBookCover extends StatelessWidget {
  const PlainTextBookCover({super.key, required this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      color: getRandomDarkColor(),
      padding: const EdgeInsets.all(4.0),
      child: Text(
        title ?? 'No Title',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
        softWrap: true,
      ),
    );
  }
}
