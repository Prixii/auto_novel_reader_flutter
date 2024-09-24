part of 'model.dart';

@freezed
class NovelAppearanceConfig with _$NovelAppearanceConfig {
  const factory NovelAppearanceConfig({
    @Default(14) int fontSize,
    @Default(false) bool boldFont,

    // 分页阅览
    @Default(NovelRenderType.streaming) NovelRenderType renderType,
    @Default(20.0) double horizontalMargin,
    @Default(20.0) double verticalMargin,
  }) = _NovelAppearanceConfig;

  factory NovelAppearanceConfig.fromJson(Map<String, dynamic> json) =>
      _$NovelAppearanceConfigFromJson(json);
}
