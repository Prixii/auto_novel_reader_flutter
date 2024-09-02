import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge(
    this.info, {
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    super.key,
  });

  final String info;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.withOpacity(0.5),
        ),
        child: Text(
          info,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ));
  }
}
