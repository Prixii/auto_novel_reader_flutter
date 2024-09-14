part of 'model.dart';

@freezed
class WenkuSearchData with _$WenkuSearchData {
  const factory WenkuSearchData({
    @Default(0) int page,
    @Default(18) int pageSize,
    @Default(1) int level,
    String? query,
  }) = _WenkuSearchData;
}

@freezed
class WebSearchData with _$WebSearchData {
  const factory WebSearchData({
    @Default(0) int page,
    @Default(20) int pageSize,
    @Default(
        ['kakuyomu', 'syosetu', 'novelup', 'hameln', 'pixiv', 'alphapolis'])
    List<String> provider,
    @Default(0) int type,
    @Default(1) int level,
    @Default(0) int translate,
    @Default(0) int sort,
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
