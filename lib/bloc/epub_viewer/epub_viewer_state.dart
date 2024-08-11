part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerState with _$EpubViewerState {
  const factory EpubViewerState.initial({
    @Default(0) int currentChapterIndex,
    @Default([]) List<String> htmlData,
    @Default('') String title,
    @Default('') String author,
    @Default([]) List<String> chapterResourceList,
    @Default(null) ScrollController? scrollController,
  }) = _Initial;
}
