part of 'web_home_bloc.dart';

@freezed
class WebHomeEvent with _$WebHomeEvent {
  const factory WebHomeEvent.init() = _Init;
  const factory WebHomeEvent.refreshFavoredWeb() = _RefreshFavoredWeb;
  const factory WebHomeEvent.toNovelDetail(String providerId, String novelId) =
      _ToNovelDetail;
  const factory WebHomeEvent.readChapter(String? chapterId,
      {@Default(false) bool loadNext}) = _ReadChapter;
  const factory WebHomeEvent.nextChapter() = _NextChapter;
  const factory WebHomeEvent.previousChapter() = _PreviousChapter;
  const factory WebHomeEvent.closeNovel() = _CloseNovel;
  const factory WebHomeEvent.leaveDetail() = _LeaveDetail;
  const factory WebHomeEvent.favorNovel(NovelType type) = _FavorNovel;
  const factory WebHomeEvent.unFavorNovel(NovelType type) = _UnFavorNovel;
}
