import 'package:flutter/material.dart';

final styleManager = _StyleManager();

class _StyleManager {
  late ThemeData _theme;

  setTheme(ThemeData theme) {
    _theme = theme;
  }

  TextStyle? get primaryColorTitleSmall =>
      _theme.textTheme.titleSmall?.copyWith(
        color: _theme.colorScheme.primary,
      );
  TextStyle? get primaryColorTitleLarge =>
      _theme.textTheme.titleLarge?.copyWith(
        color: _theme.colorScheme.primary,
      );
  TextStyle? get greyTitleMedium => _theme.textTheme.titleMedium?.copyWith(
        color: Colors.grey,
      );

  TextStyle? get titleSmall => _theme.textTheme.titleSmall;

  TextStyle? get tipText =>
      _theme.textTheme.bodySmall?.copyWith(color: Colors.grey);
  ColorScheme get colorScheme => _theme.colorScheme;
  TextTheme get textTheme => _theme.textTheme;
}
