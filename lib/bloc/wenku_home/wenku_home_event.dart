part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeEvent with _$WenkuHomeEvent {
  const factory WenkuHomeEvent.init() = _Init;
  const factory WenkuHomeEvent.toWenkuDetail(String wenkuId) = _ToWenkuDetail;
  const factory WenkuHomeEvent.favorNovel({
    required String novelId,
    @Default('default') String favoredId,
  }) = _FavorNovel;
  const factory WenkuHomeEvent.unFavorNovel({
    required String novelId,
    @Default('default') String favoredId,
  }) = _UnFavorNovel;
  const factory WenkuHomeEvent.searchWenku({
    @Default(1) int level,
    String? query,
  }) = _SearchWenku;
  const factory WenkuHomeEvent.loadNextPageWenku() = _LoadNextPageWenku;
}
