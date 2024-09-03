import 'package:flutter/material.dart';

final styleManager = _StyleManager();

class _StyleManager {
  late ThemeData theme;

  setTheme(ThemeData theme) {
    this.theme = theme;
  }

  TextStyle? get primaryColorTitleSmall => theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
      );
  TextStyle? get primaryColorTitleLarge => theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.primary,
      );
  TextStyle? get greyTitleMedium => theme.textTheme.titleMedium?.copyWith(
        color: Colors.grey,
      );

  TextStyle? get originalText => theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey,
      );
  TextStyle? get zhText => theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimaryContainer,
      );

  TextStyle? get titleSmall => theme.textTheme.titleSmall;
  TextStyle? get boldMediumTitle =>
      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get tipText =>
      theme.textTheme.bodySmall?.copyWith(color: Colors.grey);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Color get warnContainer => const Color(0xfffdf6ec);
  Color get onWarnContainer => const Color(0xffe6a23c);
  Color get succeedContainer => const Color(0xfff0f9eb);
  Color get onSucceedContainer => const Color(0xff67c23a);
}
