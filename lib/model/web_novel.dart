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
    String providerId,
    String novelId,
    String titleJp, {
    String? titleZh,
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
    String? wenkuId,
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

List<Author> parseToAuthorList(dynamic body) {
  try {
    final authorList = <Author>[];
    for (final item in body.cast<Map<String, dynamic>>()) {
      authorList.add(Author(name: item['name'], link: item['link']));
    }
    return authorList;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);

    return [];
  }
}

List<WebNovelToc> parseTocList(dynamic body) {
  try {
    final tocList = <WebNovelToc>[];
    for (final item in body.cast<Map<String, dynamic>>()) {
      tocList.add(WebNovelToc(item['titleJp'],
          titleZh: item['titleZh'],
          chapterId: item['chapterId'],
          createAt: item['createAt']));
    }
    return tocList;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);

    return [];
  }
}

List<WebNovelOutline> parseToWebNovelOutline(dynamic body) {
  try {
    final items = (body['items'] ?? []) as List<dynamic>;
    var webNovelOutlines = <WebNovelOutline>[];
    for (final item in items) {
      webNovelOutlines.add(
        WebNovelOutline(
          item['titleJp'],
          item['providerId'],
          item['novelId'],
          titleZh: item['titleZh'] ?? '',
          type: item['type'] ?? '未知',
          attentions: item['attentions'].cast<String>(),
          keywords: item['keywords'].cast<String>(),
          total: item['total'],
          jp: item['jp'],
          baidu: item['baidu'],
          youdao: item['youdao'],
          gpt: item['gpt'],
          sakura: item['sakura'],
          updateAt: item['updateAt'],
          extra: item['extra'],
        ),
      );
    }
    return webNovelOutlines;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);

    return [];
  }
}

extension WebNovelDtoExt on WebNovelDto {
  String get novelKey => '$providerId-$novelId';
}
