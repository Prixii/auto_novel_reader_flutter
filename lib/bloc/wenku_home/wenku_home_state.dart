part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeState with _$WenkuHomeState {
  const factory WenkuHomeState.initial({
    List<WenkuNovelOutline>? wenkuLatestUpdate,
    // 缓存
    @Default({}) Map<String, WenkuNovelDto> wenkuNovelDtoMap,

    // 详情
    @Default(false) bool loadingDetail,
    @Default('') String currentNovelId,
    @Default(Language.zhJp) Language language,
    @Default(TranslationMode.priority) TranslationMode translationMode,
    @Default([
      TranslationSource.sakura,
      TranslationSource.gpt,
      TranslationSource.youdao,
      TranslationSource.baidu,
    ])
    List<TranslationSource> translationOrder,
    WenkuNovelDto? currentWenkuNovelDto,
  }) = _Initial;
}
