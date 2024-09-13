part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeState with _$WenkuHomeState {
  const factory WenkuHomeState.initial({
    @Default({}) Map<RequestLabel, LoadingStatus?> loadingStatusMap,
    List<WenkuNovelOutline>? wenkuLatestUpdate,
    // 缓存
    @Default({}) Map<String, WenkuNovelDto> wenkuNovelDtoMap,
    // 收藏状态
    @Default({}) Map<String, bool> favoredWenkuMap,
    @Default({}) Map<String, WenkuNovelOutline> wenkuNovelOutlineMap,

    // 详情
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

    // 搜索
    @Default(false) bool searchingWenku,
    @Default(0) int currentWenkuSearchPage,
    @Default(-1) int maxPage,
    @Default([]) List<WenkuNovelOutline> wenkuNovelSearchResult,
    @Default(0) int wenkuLevel,
    String? wenkuQuery,
  }) = _Initial;
}
