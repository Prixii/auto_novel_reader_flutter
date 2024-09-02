import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge(
    this.info, {
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundColor,
    this.fontColor,
    super.key,
  });

  final String info;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor ?? Colors.grey.withOpacity(0.5),
        ),
        child: Text(
          info,
          style: TextStyle(color: fontColor ?? Colors.white, fontSize: 12),
        ));
  }
}
