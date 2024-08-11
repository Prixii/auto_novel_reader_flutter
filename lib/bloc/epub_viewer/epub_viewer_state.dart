part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerState with _$EpubViewerState {
  const factory EpubViewerState.initial({
    @Default(0) int currentPage,
    @Default('') String htmlData,
    @Default('') String title,
    @Default('') String author,
  }) = _Initial;
}
