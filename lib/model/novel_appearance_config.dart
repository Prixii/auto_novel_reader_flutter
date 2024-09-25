part of 'model.dart';

@freezed
class NovelAppearanceConfig with _$NovelAppearanceConfig {
  const factory NovelAppearanceConfig({
    @Default(14) int fontSize,
    @Default(false) bool boldFont,

    // 分页阅览
    @Default(NovelRenderType.streaming) NovelRenderType renderType,
    @Default(30.0) double horizontalMargin,
    @Default(40.0) double verticalMargin,
  }) = _NovelAppearanceConfig;

  factory NovelAppearanceConfig.fromJson(Map<String, dynamic> json) =>
      _$NovelAppearanceConfigFromJson(json);
}

extension NovelAppearanceConfigExt on NovelAppearanceConfig {
  TextStyle get textStyle => TextStyle(
        color: Colors.black,
        fontSize: fontSize.toDouble(),
        fontWeight: boldFont ? FontWeight.bold : FontWeight.normal,
      );
  Size get pageSize => Size(
        screenSize.width - horizontalMargin * 2,
        screenSize.height - verticalMargin * 2,
      );
}
