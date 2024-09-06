import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class IntroductionCard extends StatefulWidget {
  const IntroductionCard({
    super.key,
    required this.content,
    this.style,
  });

  final String content;
  final TextStyle? style;

  @override
  State<IntroductionCard> createState() => _IntroductionCardState();
}

class _IntroductionCardState extends State<IntroductionCard> {
  int maxLines = 3;
  bool expand = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: double.infinity),
            Text(
              widget.content,
              style: widget.style,
              maxLines: expand ? null : maxLines,
              overflow: expand ? null : TextOverflow.ellipsis,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  expand = !expand;
                });
              },
              child: Text(
                expand ? '收起' : '展开',
                style: styleManager.primaryColorTitleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
