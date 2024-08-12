import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge(
    this.info, {
    super.key,
  });

  final String info;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.withOpacity(0.5),
        ),
        child: Text(
          info,
          style: const TextStyle(color: Colors.white),
        ));
  }
}
