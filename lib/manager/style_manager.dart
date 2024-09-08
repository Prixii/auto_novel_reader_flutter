import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

final styleManager = _StyleManager();

class _StyleManager {
  final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF18A058),
    useMaterial3: true,
    searchBarTheme: const SearchBarThemeData(),
    dividerColor: Colors.grey[300],
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
    }),
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF18A058),
    useMaterial3: true,
    searchBarTheme: const SearchBarThemeData(),
    dividerColor: Colors.grey[300],
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
    }),
  );

  TextStyle? primaryColorTitleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          );
  TextStyle? primaryColorTitleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          );
  TextStyle? greyTitleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey,
          );

  TextStyle? originalText(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          );
  TextStyle? zhText(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme(context).onPrimaryContainer,
          );

  TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          );
  TextStyle? boldMediumTitle(BuildContext context) =>
      textTheme(context).titleMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? tipText(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey);
  ColorScheme colorScheme(BuildContext context) =>
      Theme.of(context).colorScheme;
  TextTheme textTheme(BuildContext context) => Theme.of(context).textTheme;
  Color get warnContainer => const Color(0xfffdf6ec);
  Color get onWarnContainer => const Color(0xffe6a23c);
  Color get succeedContainer => const Color(0xfff0f9eb);
  Color get onSucceedContainer => const Color(0xff67c23a);
  Color get errorContainer => const Color(0xfffef0f0);
  Color get onErrorContainer => const Color(0xfff56c6c);
}
