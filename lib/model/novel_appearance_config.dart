part of 'model.dart';

@freezed
class NovelAppearanceConfig with _$NovelAppearanceConfig {
  const factory NovelAppearanceConfig({
    @Default(14) int fontSize,
    @Default(false) bool boldFont,
  }) = _NovelAppearanceConfig;

  factory NovelAppearanceConfig.fromJson(Map<String, dynamic> json) =>
      _$NovelAppearanceConfigFromJson(json);
}
