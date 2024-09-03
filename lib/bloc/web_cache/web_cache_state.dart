part of 'web_cache_cubit.dart';

@freezed
class WebCacheState with _$WebCacheState {
  const factory WebCacheState.initial({
    // [providerId+novelId] -> lastReadChapter
    @Default({}) Map<String, String> lastReadChapterMap,
    // 历史
    @Default([]) List<String> webSearchHistoryQueries,
    @Default([]) List<String> webSearchHistoryTags,
    @Default([]) List<String> wenkuSearchHistoryQueries,
    @Default([]) List<String> wenkuSearchHistoryTags,
    // 收藏
    @Default([]) List<Favored> localFavored,
    @Default([]) List<Favored> webFavored,
    @Default([]) List<Favored> wenkuFavored,
  }) = _Initial;
  factory WebCacheState.fromJson(Map<String, dynamic> json) =>
      _$WebCacheStateFromJson(json);
}
