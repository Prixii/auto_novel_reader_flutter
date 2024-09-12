part of 'web_home_bloc.dart';

@freezed
class WebHomeEvent with _$WebHomeEvent {
  const factory WebHomeEvent.setWebMostVisited(
    List<WebNovelOutline> webMostVisited,
  ) = _SetWebMostVisited;
  const factory WebHomeEvent.setLoadingState(
    Map<RequestLabel, LoadingStatus?> loadingStatusMap,
  ) = _SetSetLoadingState;
  const factory WebHomeEvent.setWebFavored(
    List<WebNovelOutline> webFavored,
  ) = _SetWebFavored;
  const factory WebHomeEvent.toNovelDetail(String providerId, String novelId) =
      _ToNovelDetail;
  const factory WebHomeEvent.readChapter(String? chapterId,
      {@Default(false) bool loadNext}) = _ReadChapter;
  const factory WebHomeEvent.nextChapter() = _NextChapter;
  const factory WebHomeEvent.previousChapter() = _PreviousChapter;
  const factory WebHomeEvent.closeNovel() = _CloseNovel;
  const factory WebHomeEvent.leaveDetail() = _LeaveDetail;
  const factory WebHomeEvent.favorNovel(NovelType type,
      {@Default('default') String favoredId}) = _FavorNovel;
  const factory WebHomeEvent.unFavorNovel(NovelType type,
      {@Default('default') String favoredId}) = _UnFavorNovel;
  const factory WebHomeEvent.searchWeb({
    @Default(
        ['kakuyomu', 'syosetu', 'novelup', 'hameln', 'pixiv', 'alphapolis'])
    List<String> provider,
    @Default(0) int type,
    @Default(1) int level,
    @Default(0) int translate,
    @Default(0) int sort,
    String? query,
  }) = _SearchWeb;
  const factory WebHomeEvent.loadNextPageWeb() = _LoadNextPageWeb;
}
