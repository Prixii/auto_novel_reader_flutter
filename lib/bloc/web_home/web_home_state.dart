part of 'web_home_bloc.dart';

@freezed
class WebHomeState with _$WebHomeState {
  const factory WebHomeState.initial({
    @Default({}) Map<RequestLabel, LoadingStatus?> loadingStatusMap,
    List<WebNovelOutline>? webMostVisited,
    @Default({}) Map<String, WebNovelOutline> favoredWebMap,

    // 小说大纲缓存
    @Default({}) Map<String, WebNovelOutline> webNovelOutlineMap,

    // 小说详情
    WebNovelDto? currentWebNovelDto,
    @Default({}) Map<String, WebNovelDto?> webNovelDtoMap,
    // 小说正文
    @Default(false) bool loadingNovelChapter,
    @Default({}) Map<String, ChapterDto?> chapterDtoMap, // 原始章节数据
    @Default({}) Map<String, List<PagedData>?> chapterPagedDataMap, // 分页数据
    ChapterDto? currentChapterDto,
    List<PagedData>? currentPagedData,
    // 搜索 web
    @Default(WebSearchData()) WebSearchData webSearchData,
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
