import 'package:flutter/material.dart';

class IconOption extends StatelessWidget {
  const IconOption({
    super.key,
    required this.icon,
    this.padding = const EdgeInsets.fromLTRB(32, 16, 32, 16),
    required this.text,
    this.height = 28,
    this.onTap,
    this.color,
    this.bold = false,
  });

  final void Function()? onTap;
  final double height;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color ?? theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color ?? theme.colorScheme.onSecondaryContainer,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
