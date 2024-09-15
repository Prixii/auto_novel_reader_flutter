part of 'history_cubit.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState.initial({
    @Default({}) Map<RequestLabel, LoadingStatus?> loadingStatusMap,
    @Default([]) List<WebNovelOutline> histories,
    @Default(0) int currentPage,
    @Default(0) int maxPage,
    @Default(false) bool isRequesting,
  }) = _Initial;
}
