import 'package:flutter/material.dart';

class NavTitle extends StatelessWidget {
  const NavTitle({
    super.key,
    required this.title,
    required this.jumpTo,
    this.prefix,
  });

  final Widget? prefix;
  final String title;
  final Function jumpTo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          prefix ?? const SizedBox.shrink(),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Container()),
          // TODO 跳转按钮
          // IconButton(
          //   onPressed: () => jumpTo(),
          //   icon: const Icon(Icons.chevron_right),
          // )
        ],
      ),
    );
  }
}
