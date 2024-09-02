part of 'web_home_bloc.dart';

@freezed
class WebHomeEvent with _$WebHomeEvent {
  const factory WebHomeEvent.init() = _Init;
  const factory WebHomeEvent.refreshFavoredWeb() = _RefreshFavoredWeb;
  const factory WebHomeEvent.toNovelDetail(String providerId, String novelId) =
      _ToNovelDetail;
}
