part of 'model.dart';

@freezed
class Author with _$Author {
  const factory Author({
    required String name,
    required String link,
  }) = _Author;
}

@freezed
class WebNovel with _$WebNovel {
  const factory WebNovel.webNovelOutline(
    String titleJp,
    String providerId,
    String novelId, {
    String? titleZh,
    String? extra,
    @Default([]) List<String> keywords,
    @Default([]) List<String> attentions,
    @Default('连载中') String type,
    //
    String? favored,
    int? lastReadAt,
    //
    @Default(0) int total,
    @Default(0) int baidu,
    @Default(0) int gpt,
    @Default(0) int jp,
    @Default(0) int sakura,
    @Default(0) int youdao,
    int? updateAt,
  }) = WebNovelOutline;

  const factory WebNovel.webNovelToc(
    String titleJp, {
    String? titleZh,
    String? chapterId,
    int? createAt,
  }) = WebNovelToc;

  const factory WebNovel.webNovelDto(
    String titleJp, {
    @Default([]) List<Author> authors,
    required String type,
    @Default([]) List<String> keywords,
    @Default([]) List<String> attentions,
    int? points,
    int? totalCharacters,
    required String introductionJp,
    String? introductionZh,
    @Default({}) Map<String, String> glossary,
    @Default([]) List<WebNovelToc>? toc,
    required int visited,
    required int syncAt,
    String? favored,
    String? lastReadChapterId,
    int? jp,
    int? baidu,
    int? youdao,
    int? gpt,
    int? sakura,
  }) = WebNovelDto;

  const factory WebNovel.webNovelChapter(
    String titleJp, {
    String? titleZh,
    String? prevId,
    String? nextId,
    @Default([]) List<String> paragraphs,
    List<String>? baiduParagraphs,
    List<String>? youdaoParagraphs,
    List<String>? gptParagraphs,
    List<String>? sakuraParagraphs,
  }) = WebNovelChapter;
}
