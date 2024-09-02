import 'package:flutter/material.dart';

final styleManager = _StyleManager();

class _StyleManager {
  late ThemeData _theme;

  setTheme(ThemeData theme) {
    _theme = theme;
  }

  TextStyle? get primaryColorTitle => _theme.textTheme.titleSmall?.copyWith(
        color: _theme.colorScheme.primary,
      );

  TextStyle? get titleSmall => _theme.textTheme.titleSmall;

  TextStyle? get tipText =>
      _theme.textTheme.bodySmall?.copyWith(color: Colors.grey);
  ColorScheme get colorScheme => _theme.colorScheme;
  TextTheme get textTheme => _theme.textTheme;
}
