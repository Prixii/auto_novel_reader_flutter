part of 'epub_viewer_bloc.dart';

@freezed
class EpubViewerEvent with _$EpubViewerEvent {
  const factory EpubViewerEvent.open(File epub, BuildContext context) = _Open;
  const factory EpubViewerEvent.nextChapter() = _NextChapter;
  const factory EpubViewerEvent.previousChapter() = _PreviousChapter;
  const factory EpubViewerEvent.goToChapter(int index) = _GoToChapter;
  const factory EpubViewerEvent.clickUrl(String url) = _ClickUrl;
  const factory EpubViewerEvent.close() = _Close;
  const factory EpubViewerEvent.openSettings() = _OpenSettings;
  const factory EpubViewerEvent.setScrollController(
      ScrollController controller) = _SetScrollController;
  const factory EpubViewerEvent.updateReadingProgress(int progress) =
      _UpdateReadingProgress;
  const factory EpubViewerEvent.switchChapter(int index) = _SwitchChapter;
}
