part of 'web_home_bloc.dart';

@freezed
class WebHomeState with _$WebHomeState {
  const factory WebHomeState.initial({
    @Default(false) bool inInit,
    List<WenkuNovelOutline>? wenkuLatestUpdate,
    List<WebNovelOutline>? webMostVisited,
    List<WebNovelOutline>? favoredWeb,
    //
    @Default({}) Map<String, WebNovelDto> webNovelDtoMap,
    String? currentNovelId,
    String? currentNovelProviderId,
    @Default(false) bool loadingNovelDetail,
  }) = _Initial;
}
