part of 'web_home_bloc.dart';

@freezed
class WebHomeEvent with _$WebHomeEvent {
  const factory WebHomeEvent.setLoadingStatus(
    Map<RequestLabel, LoadingStatus?> loadingStatusMap,
  ) = _SetLoadingStatus;

  // 首页
  const factory WebHomeEvent.setWebMostVisited(
    List<WebNovelOutline> webMostVisited,
  ) = _SetWebMostVisited;
  const factory WebHomeEvent.setWebFavored(
    List<WebNovelOutline> webFavored,
  ) = _SetWebFavored;
  const factory WebHomeEvent.setWebNovelOutlines(
    List<WebNovelOutline> webOutlines,
  ) = _SetWebNovelOutlines;

  // 阅读
  const factory WebHomeEvent.toNovelDetail(String providerId, String novelId) =
      _ToNovelDetail;
  const factory WebHomeEvent.readChapter(String? chapterId,
      {@Default(false) bool loadNext}) = _ReadChapter;
  const factory WebHomeEvent.nextChapter() = _NextChapter;
  const factory WebHomeEvent.previousChapter() = _PreviousChapter;
  const factory WebHomeEvent.closeNovel() = _CloseNovel;
  const factory WebHomeEvent.leaveDetail() = _LeaveDetail;

  // 收藏
  const factory WebHomeEvent.favorNovel(NovelType type,
      {@Default('default') String favoredId}) = _FavorNovel;
  const factory WebHomeEvent.unFavorNovel(NovelType type,
      {@Default('default') String favoredId}) = _UnFavorNovel;

  // 搜搜索
  const factory WebHomeEvent.searchWeb(WebSearchData data) = _SearchWeb;
  const factory WebHomeEvent.loadNextPageWeb() = _LoadNextPageWeb;
}
