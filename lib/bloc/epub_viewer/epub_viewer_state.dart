part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerState with _$EpubViewerState {
  const factory EpubViewerState.initial({
    @Default(0) int currentChapterIndex,
    @Default('') String htmlData,
    @Default('') String title,
    @Default('') String author,
    @Default([]) List<String> chapterResourceList,
  }) = _Initial;
}
