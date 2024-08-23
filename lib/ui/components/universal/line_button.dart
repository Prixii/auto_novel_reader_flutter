import 'package:flutter/material.dart';

class LineButton extends StatelessWidget {
  const LineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.bottomPadding = 0,
    this.textColor,
    this.backgroundColor,
  });
  final void Function()? onPressed;
  final String text;
  final double bottomPadding;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              backgroundColor ?? theme.colorScheme.primaryContainer,
        ),
        onPressed: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: textColor ?? theme.colorScheme.onPrimaryContainer),
            ),
          ),
        ),
      ),
    );
  }
}
