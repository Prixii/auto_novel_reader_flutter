part of 'model.dart';

@freezed
class WenkuSearchData with _$WenkuSearchData {
  const factory WenkuSearchData({
    @Default(0) int page,
    @Default(18) int pageSize,
    @Default(WenkuNovelLevel.general) WenkuNovelLevel level,
    String? query,
  }) = _WenkuSearchData;
}

@freezed
class WebSearchData with _$WebSearchData {
  const factory WebSearchData({
    @Default(0) int page,
    @Default(20) int pageSize,
    @Default([
      NovelProvider.kakuyomu,
      NovelProvider.syosetu,
      NovelProvider.novelup,
      NovelProvider.hameln,
      NovelProvider.pixiv,
      NovelProvider.alphapolis,
    ])
    List<NovelProvider> provider,
    @Default(NovelStatus.all) NovelStatus type,
    @Default(WebNovelLevel.general) WebNovelLevel level,
    @Default(WebTranslationSource.all) WebTranslationSource translate,
    @Default(WebNovelOrder.update) WebNovelOrder sort,
    String? query,
  }) = _WebSearchData;
}

@freezed
class HistorySearchData with _$HistorySearchData {
  const factory HistorySearchData({
    @Default(0) int page,
    @Default(16) int pageSize,
  }) = _HistorySearchData;
}
