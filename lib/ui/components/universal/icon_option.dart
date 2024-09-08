import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class IconOption extends StatelessWidget {
  const IconOption({
    super.key,
    this.icon,
    this.prefix,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 32, 12),
    required this.text,
    this.height = 28,
    this.onTap,
    this.color,
    this.bold = false,
    this.tip,
  });

  final void Function()? onTap;
  final double height;
  final IconData? icon;
  final Widget? prefix;
  final EdgeInsetsGeometry padding;
  final String text;
  final Color? color;
  final bool bold;
  final String? tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBody(theme),
            if (tip != null) ..._buildTip(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) prefix!,
          if (icon != null)
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
    );
  }

  List<Widget> _buildTip(BuildContext context) {
    return [
      const SizedBox(height: 4),
      Text(tip!, style: styleManager.tipText(context))
    ];
  }
}
