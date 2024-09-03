import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<List<WebNovelOutline>> loadFavoredWebOutline({
  String favoredId = 'default',
  int page = 0,
  int pageSize = 8,
  String sort = 'update',
}) async {
  return apiClient.userFavoredWebService
      .getIdList(
    favoredId: favoredId,
    page: page,
    pageSize: pageSize,
    sort: sort,
  )
      .then((response) {
    if (response?.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return [];
    }
    final body = response?.body;
    final webNovelOutlines = parseToWebNovelOutline(body);
    return webNovelOutlines;
  });
}

Future<List<WebNovelOutline>> loadPagedWebOutline({
  int page = 0,
  int pageSize = 8,
  String provider = '',
  int type = 0,
  int level = 1,
  int translate = 0,
  int sort = 1,
  String? query,
}) async {
  return apiClient.webNovelService
      .getList(
    page,
    pageSize,
    provider: provider,
    type: type,
    level: level,
    translate: translate,
    sort: sort,
    query: query,
  )
      .then((response) {
    final body = response.body;
    final webNovelOutlines = parseToWebNovelOutline(body);
    return webNovelOutlines;
  });
}

Future<List<WenkuNovelOutline>> loadPagedWenkuOutline({
  int page = 0,
  int pageSize = 12,
  int level = 0,
  String? query,
}) async {
  return apiClient.wenkuNovelService
      .getList(
    page,
    pageSize,
    level: level,
    query: query,
  )
      .then((response) {
    final body = response.body;
    final wenkuNovelOutlines = parseToWenkuNovelOutline(body);
    return wenkuNovelOutlines;
  });
}

String findChapterId(WebNovelDto webNovelDto) {
  final tocList = webNovelDto.toc;
  // 未读过
  if (webNovelDto.lastReadChapterId == null) {
    return _findFirstChapterInToc(tocList ?? []);
  }

  // 读过
  String? targetChapterId;
  if (tocList == null) {
    throw Exception('webNovelDto.toc is null');
  } else {
    for (final toc in tocList) {
      if (toc.chapterId != null &&
          toc.chapterId == webNovelDto.lastReadChapterId) {
        targetChapterId = toc.chapterId!;
        break;
      }
    }
  }
  if (targetChapterId == null) {
    Fluttertoast.showToast(msg: '没有找到上次阅读的章节, 将从第一章开始阅读');
    targetChapterId = _findFirstChapterInToc(tocList);
  }
  return targetChapterId;
}

String _findFirstChapterInToc(List<WebNovelToc> tocList) {
  for (final toc in tocList) {
    if (toc.chapterId != null) {
      return toc.chapterId!;
    }
  }
  throw Exception('webNovelDto.toc is null');
}

Future<ChapterDto?> requestNovelChapter(
  String providerId,
  String novelId,
  String chapterId,
) async {
  final response = await apiClient.webNovelService
      .getChapter(providerId, novelId, chapterId);
  if (response.statusCode == 502) {
    Fluttertoast.showToast(msg: '服务器维护中');
    return null;
  }
  final body = response.body;
  try {
    final chapterDto = ChapterDto(
      baiduParagraphs: body['youdaoParagraphs']?.cast<String>(),
      originalParagraphs: body['paragraphs']?.cast<String>(),
      youdaoParagraphs: body['youdaoParagraphs']?.cast<String>(),
      gptParagraphs: body['gptParagraphs']?.cast<String>(),
      sakuraParagraphs: body['sakuraParagraphs']?.cast<String>(),
      previousId: body['prevId'],
      nextId: body['nextId'],
      titleJp: body['titleJp'],
      titleZh: body['titleZh'],
    );
    return chapterDto;
  } catch (e) {
    talker.error(e);
    return null;
  }
}
