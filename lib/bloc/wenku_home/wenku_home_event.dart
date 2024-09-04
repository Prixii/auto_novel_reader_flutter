part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeEvent with _$WenkuHomeEvent {
  const factory WenkuHomeEvent.init() = _Init;
  const factory WenkuHomeEvent.toDetail(String novelId) = _ToDetail;
  const factory WenkuHomeEvent.favorNovel() = _FavorNovel;
  const factory WenkuHomeEvent.unFavorNovel() = _UnFavorNovel;
  const factory WenkuHomeEvent.searchWenku({
    @Default(1) int level,
    String? query,
  }) = _SearchWenku;
  const factory WenkuHomeEvent.loadNextPageWenku() = _LoadNextPageWenku;
}
