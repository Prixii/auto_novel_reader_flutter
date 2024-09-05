part of 'favored_cubit.dart';

@freezed
class FavoredState with _$FavoredState {
  const factory FavoredState.initial({
    @Default({
      NovelType.web: [],
      NovelType.wenku: [],
      NovelType.local: [],
    })
    Map<NovelType, List<Favored>> favoredMap,
    @Default(NovelType.web) NovelType currentType,
    @Default(null) Favored? currentFavored,
    // web
    @Default({}) Map<String, int> favoredWebPageMap,
    @Default({}) Map<String, int> favoredWebMaxPageMap,
    @Default({}) Map<String, List<WebNovelOutline>> favoredWebNovelsMap,
    @Default({}) Map<String, bool> isWebRequestingMap,
    @Default({}) Map<String, SearchSortType> favoredWebSortTypeMap,
    // wenku
    @Default({}) Map<String, int> favoredWenkuPageMap,
    @Default({}) Map<String, int> favoredWenkuMaxPageMap,
    @Default({}) Map<String, List<WenkuNovelOutline>> favoredWenkuNovelsMap,
    @Default({}) Map<String, bool> isWenkuRequestingMap,
    @Default({}) Map<String, SearchSortType> favoredWenkuSortTypeMap,
  }) = _Initial;
}
