part of 'web_home_bloc.dart';

@freezed
class WebHomeState with _$WebHomeState {
  const factory WebHomeState.initial({
    @Default({}) Map<RequestLabel, LoadingStatus?> loadingStatusMap,
    @Default(false) bool inInit,
    List<WebNovelOutline>? webMostVisited,
    @Default({}) Map<String, WebNovelOutline> favoredWebMap,
    // 小说大纲缓存
    @Default({}) Map<String, WebNovelOutline> webNovelOutlineMap,

    // 小说详情
    WebNovelDto? currentWebNovelDto,
    @Default({}) Map<String, WebNovelDto?> webNovelDtoMap,
    @Default(false) bool loadingNovelDetail,
    // 小说正文
    @Default(false) bool loadingNovelChapter,
    @Default({}) Map<String, ChapterDto?> chapterDtoMap,
    ChapterDto? currentChapterDto,
    // 搜索 web
    @Default(false) bool searchingWeb,
    @Default([]) List<WebNovelOutline> webNovelSearchResult,
    @Default(0) int currentWebSearchPage,
    @Default(-1) int maxPage,
    @Default(0) int webType,
    @Default(1) int webLevel,
    @Default(0) int webTranslate,
    @Default(0) int webSort,
    @Default([]) List<String> webProvider,
    String? webQuery,
  }) = _Initial;
}
