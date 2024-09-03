part of 'wenku_home_bloc.dart';

@freezed
class WenkuHomeState with _$WenkuHomeState {
  const factory WenkuHomeState.initial({
    List<WenkuNovelOutline>? wenkuLatestUpdate,
    // 缓存
    @Default({}) Map<String, WenkuNovelDto> wenkuNovelDtoMap,

    // 详情
    @Default(false) bool loadingDetail,
    @Default('') String currentNovelId,
    WenkuNovelDto? currentWenkuNovelDto,
  }) = _Initial;
}
