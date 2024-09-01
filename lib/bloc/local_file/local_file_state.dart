part of 'local_file_cubit.dart';

@freezed
class LocalFileState with _$LocalFileState {
  const factory LocalFileState.initial({
    @Default([]) List<EpubManageData> epubManageDataList,
  }) = _Initial;

  factory LocalFileState.fromJson(Map<String, dynamic> json) =>
      _$LocalFileStateFromJson(json);
}
