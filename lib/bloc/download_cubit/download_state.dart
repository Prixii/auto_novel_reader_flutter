part of 'download_cubit.dart';

@freezed
class DownloadState with _$DownloadState {
  const factory DownloadState.initial({
    @Default({}) Map<String, double> progressMap,
    @Default({}) Set<String> parseMap,
    @Default([]) List<(String, String)> downloadHistory,
  }) = _Initial;
}
