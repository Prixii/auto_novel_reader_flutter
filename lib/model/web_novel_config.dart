part of 'model.dart';

@freezed
class WebNovelConfig with _$WebNovelConfig {
  const factory WebNovelConfig({
    @Default(Language.zhJp) Language language,
    @Default(TranslationMode.priority) TranslationMode translationMode,
    @Default([
      TranslationSource.sakura,
      TranslationSource.gpt,
      TranslationSource.youdao,
      TranslationSource.baidu
    ])
    List<TranslationSource> translationSourcesOrder,
    @Default({
      TranslationSource.sakura: true,
      TranslationSource.gpt: true,
      TranslationSource.youdao: true,
      TranslationSource.baidu: true
    })
    Map<TranslationSource, bool> translationSourcesEnabled,
    @Default(Language.zh) Language readLanguage,
    @Default(false) bool showTranslationSource,
    @Default(false) bool enableTrim,
    @Default(true) bool sakuraErrorReport,
  }) = _WebNovelConfig;

  factory WebNovelConfig.fromJson(Map<String, dynamic> json) =>
      _$WebNovelConfigFromJson(json);
}
