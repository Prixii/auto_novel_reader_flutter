import 'package:flutter/material.dart';

class LineButton extends StatelessWidget {
  const LineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.onDisabledPressed,
    this.bottomPadding = 0,
    this.textColor,
    this.backgroundColor,
    this.enabled = true,
  });
  final void Function()? onPressed;
  final void Function()? onDisabledPressed;
  final String text;
  final double bottomPadding;
  final Color? textColor;
  final Color? backgroundColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: GestureDetector(
        onTap: enabled ? null : onDisabledPressed,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                backgroundColor ?? theme.colorScheme.secondaryContainer,
          ),
          onPressed: enabled ? onPressed : null,
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: textColor ?? theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
