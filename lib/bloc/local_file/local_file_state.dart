part of 'local_file_cubit.dart';

@freezed
class LocalFileState with _$LocalFileState {
  const factory LocalFileState.initial({
    @Default([]) List<EpubManageData> epubManageDataList,
    @Default(0) int progress,
    @Default('') String message,
    @Default(false) bool loading,
  }) = _Initial;
}
