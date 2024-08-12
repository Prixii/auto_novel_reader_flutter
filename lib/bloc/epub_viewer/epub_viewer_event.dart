part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerEvent with _$EpubViewerEvent {
  const factory EpubViewerEvent.open(
      File epub, EpubManageData epubManageData, BuildContext context) = _Open;
  const factory EpubViewerEvent.nextChapter() = _NextChapter;
  const factory EpubViewerEvent.previousChapter() = _PreviousChapter;
  const factory EpubViewerEvent.clickUrl(String url) = _ClickUrl;
  const factory EpubViewerEvent.close(double progress) = _Close;
  const factory EpubViewerEvent.openSettings() = _OpenSettings;
  const factory EpubViewerEvent.setScrollController(
      ScrollController controller) = _SetScrollController;
  const factory EpubViewerEvent.switchChapter(int index, double readProgress,
      {bool? canPop}) = _SwitchChapter;
}
