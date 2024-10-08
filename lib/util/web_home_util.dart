import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<(List<WebNovelOutline>, int)> loadFavoredWebOutline({
  String favoredId = 'default',
  int page = 0,
  int pageSize = 8,
  String sort = 'update',
}) async {
  if (!userCubit.isSignIn) throw Exception('未登录');
  return apiClient.userFavoredWebService
      .getIdList(
    favoredId: favoredId,
    page: page,
    pageSize: pageSize,
    sort: sort,
  )
      .then((response) {
    final body = response?.body;
    final webNovelOutlines = parseToWebNovelOutline(body);
    favoredCubit.setNovelToFavoredIdMap(webOutlines: webNovelOutlines.toList());

    return (webNovelOutlines, body['pageNumber'] as int);
  });
}

Future<List<WebNovelOutline>> loadPagedWebOutlines(WebSearchData data) async {
  try {
    return apiClient.webNovelService
        .getList(
      data.page,
      data.pageSize,
      provider: data.provider.map((e) => e.name).join(','),
      type: NovelStatus.indexByZhName(data.type.zhName),
      level: WebNovelLevel.indexByZhName(data.level.zhName),
      translate: WebTranslationSource.indexByZhName(data.translate.zhName),
      sort: WebNovelOrder.indexByZhName(data.sort.zhName),
      query: data.query,
    )
        .then((response) {
      final body = response.body;
      final webNovelOutlines = parseToWebNovelOutline(body);
      favoredCubit.setNovelToFavoredIdMap(webOutlines: webNovelOutlines);

      return webNovelOutlines;
    });
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

@Deprecated('use loadPagedWebOutlines instead')
Future<(List<WebNovelOutline>, int)> loadPagedWebOutline({
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
    favoredCubit.setNovelToFavoredIdMap(webOutlines: webNovelOutlines);

    return (webNovelOutlines, body['pageNumber'] as int);
  });
}

Future<List<WenkuNovelOutline>> loadPagedWenkuOutlines(
    WenkuSearchData data) async {
  try {
    final response = await apiClient.wenkuNovelService.getList(
      data.page,
      data.pageSize,
      level: WenkuNovelLevel.indexByZhName(data.level.zhName),
      query: data.query,
    );
    final body = response.body;
    final wenkuNovelOutlines = parseToWenkuNovelOutline(body);
    favoredCubit.setNovelToFavoredIdMap(wenkuOutlines: wenkuNovelOutlines);

    return wenkuNovelOutlines;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

@Deprecated('use loadPagedWenkuOutlines instead')
Future<(List<WenkuNovelOutline>, int)> loadPagedWenkuOutline({
  int page = 0,
  int pageSize = 12,
  int level = 0,
  String? query,
}) async {
  try {
    final response = await apiClient.wenkuNovelService.getList(
      page,
      pageSize,
      level: level,
      query: query,
    );
    final body = response.body;
    final wenkuNovelOutlines = parseToWenkuNovelOutline(body);
    favoredCubit.setNovelToFavoredIdMap(wenkuOutlines: wenkuNovelOutlines);

    return (wenkuNovelOutlines, body['pageNumber'] as int);
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

Future<(List<WenkuNovelOutline>, int)> requestWenkuLatestUpdate({
  int page = 0,
  int pageSize = 12,
  int level = 0,
  String? query,
}) async {
  try {
    final response = await apiClient.wenkuNovelService.getList(
      page,
      pageSize,
      level: level,
      query: query,
    );
    final body = response.body;
    final wenkuNovelOutlines = parseToWenkuNovelOutline(body);
    favoredCubit.setNovelToFavoredIdMap(wenkuOutlines: wenkuNovelOutlines);

    return (wenkuNovelOutlines, body['pageNumber'] as int);
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
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

Future<WebNovelDto?> loadWebNovelDto(
  String providerId,
  String novelId, {
  Function? onRequest,
  Function? onRequestFinished,
}) async {
  // 检查是否有缓存
  final existDto = webHomeBloc.state.webNovelDtoMap['$providerId-$novelId'];
  if (existDto != null) {
    return existDto;
  }

  try {
    // 没有缓存，则请求
    onRequest?.call();
    final response =
        await apiClient.webNovelService.getNovelId(providerId, novelId);
    final body = response.body;
    final webNovelDto = WebNovelDto(
      providerId,
      novelId,
      body['titleJp'],
      attentions: body['attentions'].cast<String>(),
      authors: parseToAuthorList(body['authors']),
      baidu: body['baidu'],
      wenkuId: body['wenkuId'],
      favored: body['favored'],
      glossary: Map<String, String>.from(body['glossary']),
      gpt: body['gpt'],
      introductionJp: body['introductionJp'],
      introductionZh: body['introductionZh'],
      lastReadChapterId: body['lastReadChapterId'],
      jp: body['jp'],
      keywords: body['keywords'].cast<String>(),
      points: body['points'],
      sakura: body['sakura'],
      syncAt: body['syncAt'],
      titleZh: body['titleZh'],
      toc: parseTocList(body['toc']),
      totalCharacters: body['totalCharacters'],
      type: body['type'],
      visited: body['visited'],
      youdao: body['youdao'],
    );
    onRequestFinished?.call();
    favoredCubit
        .setNovelToFavoredIdMap(webNovelDtoData: (novelId, webNovelDto));
    return webNovelDto;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    onRequestFinished?.call();
    rethrow;
  }
}

Future<ChapterDto?> loadNovelChapter(
  String providerId,
  String novelId,
  String? chapterId, {
  Function? onRequest,
  Function? onRequestFinished,
}) async {
  if (chapterId == null) return null;
  final chapterKey = '$providerId-$novelId-$chapterId';

  // 检查是否有缓存
  final existDto = webHomeBloc.state.chapterDtoMap[chapterKey];
  if (existDto != null) return existDto;

  onRequest?.call();
  // 没有缓存，则请求
  final chapterDto = await _requestNovelChapter(
    providerId,
    novelId,
    chapterId,
  );
  onRequestFinished?.call();
  return chapterDto;
}

Future<ChapterDto?> _requestNovelChapter(
  String providerId,
  String novelId,
  String chapterId,
) async {
  try {
    final response = await apiClient.webNovelService
        .getChapter(providerId, novelId, chapterId);
    final body = response.body;
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
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

Future<WenkuNovelDto?> loadWenkuNovelDto(
  String novelId, {
  Function? onRequest,
  Function? onRequestFinished,
}) async {
  final existDto = wenkuHomeBloc.state.wenkuNovelDtoMap[novelId];
  if (existDto != null) return existDto;
  try {
    onRequest?.call();
    final wenkuDto = await _requestWenkuNovelDto(novelId);
    onRequestFinished?.call();
    return wenkuDto;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

Future<WenkuNovelDto?> _requestWenkuNovelDto(String novelId) async {
  try {
    final response = await apiClient.wenkuNovelService.getId(novelId);
    final body = response.body;
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return null;
    }
    final wenkuDto = WenkuNovelDto(
      novelId,
      body['title'],
      body['titleZh'],
      cover: body['cover'],
      authors: body['authors'].cast<String>(),
      artists: body['artists'].cast<String>(),
      keywords: body['keywords'].cast<String>(),
      publisher: body['publisher'],
      favored: body['favored'],
      imprint: body['imprint'],
      latestPublishAt: body['latestPublishAt'],
      level: body['level'],
      introduction: body['introduction'],
      glossary: Map<String, String>.from(body['glossary']),
      webIds: body['webIds'].cast<String>(),
      volumes: _parseWenkuVolumeList(body['volumes']),
      visited: body['visited'],
      volumeZh: body['volumeZh'].cast<String>(),
      volumeJp: _parseVolumeJpDtoList(body['volumeJp']),
    );
    favoredCubit.setNovelToFavoredIdMap(wenkuNovelDtoData: (novelId, wenkuDto));
    return wenkuDto;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    return null;
  }
}

List<VolumeJpDto> _parseVolumeJpDtoList(body) {
  var list = <VolumeJpDto>[];
  try {
    for (var item in body) {
      list.add(
        VolumeJpDto(
          item['volumeId'],
          item['total'],
          item['baidu'],
          item['youdao'],
          item['gpt'],
          item['sakura'],
        ),
      );
    }
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
  }
  return list;
}

List<WenkuVolumeDto> _parseWenkuVolumeList(body) {
  var list = <WenkuVolumeDto>[];
  try {
    for (var item in body) {
      list.add(
        WenkuVolumeDto(
          item['asin'],
          item['title'],
          titleZh: item['titleZh'],
          cover: item['cover'],
          coverHires: item['coverHires'],
          publisher: item['publisher'],
          imprint: item['imprint'],
          publishAt: item['publishAt'],
        ),
      );
    }
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
  }
  return list;
}

List<Comment> parseCommentList(body) {
  var list = <Comment>[];
  try {
    for (var item in body) {
      list.add(Comment(
        createAt: item['createAt'],
        content: item['content'],
        hidden: item['hidden'],
        id: item['id'],
        numReplies: item['numReplies'],
        user: User(
          role: item['user']['role'],
          username: item['user']['username'],
        ),
        replies: parseCommentList(item['replies']),
      ));
    }
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
  }
  return list;
}

Future<List<WebNovelOutline>> requestHistory(HistorySearchData data) async {
  try {
    final response = await apiClient.userReadHistoryWebService.getList(
      page: data.page,
      pageSize: data.pageSize,
    );
    final body = response!.body;
    final newDtoList = parseToWebNovelOutline(body);
    return newDtoList;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

Future<List<WebNovelOutline>> loadWebFavored(
  LoadFavoredData data,
) async {
  try {
    // 发送请求
    final response = await apiClient.userFavoredWebService.getIdList(
      favoredId: data.favoredId,
      page: data.page,
      pageSize: 20,
      sort: data.sort.name,
    );

    // 处理响应
    final body = response!.body;
    final newWebNovelList = parseToWebNovelOutline(body);

    return newWebNovelList;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}

Future<List<WenkuNovelOutline>> loadWenkuFavored(
  LoadFavoredData data,
) async {
  try {
    // 发送请求
    final response = await apiClient.userFavoredWenkuService.getIdList(
      favoredId: data.favoredId,
      page: data.page,
      pageSize: 20,
      sort: data.sort.name,
    );

    // 处理响应
    final body = response!.body;
    final newWenkuNovelList = parseToWenkuNovelOutline(body);

    return newWenkuNovelList;
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    rethrow;
  }
}
