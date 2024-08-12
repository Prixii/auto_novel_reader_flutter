part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerState with _$EpubViewerState {
  const factory EpubViewerState.initial({
    @Default(0) int currentChapterIndex,
    @Default([]) List<String> htmlData,
    @Default([]) List<String> chapterResourceList,
    @Default(null) ScrollController? scrollController,
    @Default(null) EpubManageData? epubManageData,
  }) = _Initial;
}
