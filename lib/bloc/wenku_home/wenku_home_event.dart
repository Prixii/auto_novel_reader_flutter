part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeEvent with _$WenkuHomeEvent {
  const factory WenkuHomeEvent.setWenkuLatestUpdate(
      List<WenkuNovelOutline> wenkuNovelOutlines) = _SetWenkuLatestUpdate;
  const factory WenkuHomeEvent.setWenkuNovelOutlines(
      List<WenkuNovelOutline> wenkuNovelOutlines) = _SetWenkuNovelOutlines;
  const factory WenkuHomeEvent.setLoadingStatus(
    Map<RequestLabel, LoadingStatus?> loadingStatusMap,
  ) = _SetSetLoadingStatus;
  const factory WenkuHomeEvent.toWenkuDetail(String wenkuId) = _ToWenkuDetail;
  const factory WenkuHomeEvent.favorNovel({
    required String novelId,
    @Default('default') String favoredId,
  }) = _FavorNovel;
  const factory WenkuHomeEvent.unFavorNovel({
    required String novelId,
    @Default('default') String favoredId,
  }) = _UnFavorNovel;
  const factory WenkuHomeEvent.setSearchData(WenkuSearchData data) =
      _SetSearchData;
}
