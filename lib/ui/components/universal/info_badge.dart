import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge(
    this.info, {
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundColor,
    this.fontColor,
    this.copyOnLongPress = true,
    super.key,
  });

  final String info;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? fontColor;
  final bool copyOnLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (copyOnLongPress) {
          await Clipboard.setData(ClipboardData(text: info));
          showSucceedToast('标签已复制到剪切板');
        }
      },
      child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: backgroundColor ?? Colors.grey.withOpacity(0.5),
          ),
          child: Text(
            info,
            style: TextStyle(color: fontColor ?? Colors.white, fontSize: 12),
          )),
    );
  }
}
