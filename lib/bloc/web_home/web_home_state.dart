part of 'web_home_bloc.dart';

@freezed
class WebHomeState with _$WebHomeState {
  const factory WebHomeState.initial({
    @Default(false) bool inInit,
    List<WenkuNovelOutline>? wenkuLatestUpdate,
    List<WebNovelOutline>? webMostVisited,
    List<WebNovelOutline>? favoredWeb,
    // 小说详情
    @Default({}) Map<String, WebNovelDto> webNovelDtoMap,
    WebNovelDto? currentWebNovelDto,
    String? currentNovelId,
    String? currentNovelProviderId,
    @Default(false) bool loadingNovelDetail,
    // 小说正文
    @Default(false) bool loadingNovelChapter,
    @Default({}) Map<String, ChapterDto> chapterDtoMap,
    ChapterDto? currentChapterDto,
  }) = _Initial;
}
