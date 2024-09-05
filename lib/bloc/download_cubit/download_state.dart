part of 'download_cubit.dart';

@freezed
class DownloadState with _$DownloadState {
  const factory DownloadState.initial({
    @Default({}) Map<String, double> taskProgress,
    @Default({}) Map<String, DownloadStatus> taskStatus,
    @Default({}) Map<String, String> taskExtraInfo,
  }) = _Initial;

  factory DownloadState.fromJson(Map<String, dynamic> json) =>
      _$DownloadStateFromJson(json);
}
