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

  TextStyle? get tipText =>
      theme.textTheme.bodySmall?.copyWith(color: Colors.grey);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
}
