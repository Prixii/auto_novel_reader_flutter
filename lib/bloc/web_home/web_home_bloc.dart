import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_home_event.dart';
part 'web_home_state.dart';
part 'web_home_bloc.freezed.dart';

class WebHomeBloc extends Bloc<WebHomeEvent, WebHomeState> {
  WebHomeBloc() : super(const _Initial()) {
    on<WebHomeEvent>((event, emit) async {
      await event.map(
        init: (event) async => await _onInit(event, emit),
        refreshFavoredWeb: (event) async =>
            await _onRefreshFavoredWeb(event, emit),
        toNovelDetail: (event) async => await _onToNovelDetail(event, emit),
        readChapter: (event) async => await _onReadChapter(event, emit),
        nextChapter: (event) async => await _onNextChapter(event, emit),
        previousChapter: (event) async => await _onPreviousChapter(event, emit),
        closeNovel: (event) async => await _onCloseNovel(event, emit),
        leaveDetail: (event) async => await _onLeaveDetail(event, emit),
        favorNovel: (event) async => await _onFavorNovel(event, emit),
        unFavorNovel: (event) async => await _onUnFavorNovel(event, emit),
      );
    });
  }

  _onInit(_Init event, Emitter<WebHomeState> emit) async {
    if (state.inInit) return;
    emit(state.copyWith(inInit: true));
    Set<WebNovelOutline> newWebOutlines = {};
    await Future.wait([
      loadFavoredWebOutline().then((webNovelOutlines) {
        var favoredWebMapSnapshot = <String, WebNovelOutline>{};
        for (var webNovelOutline in webNovelOutlines) {
          favoredWebMapSnapshot[
                  '${webNovelOutline.providerId}${webNovelOutline.novelId}'] =
              webNovelOutline;
        }
        emit(state.copyWith(favoredWebMap: favoredWebMapSnapshot));
        newWebOutlines.addAll(webNovelOutlines);
      }),
      loadPagedWebOutline(
        provider: 'kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis',
      ).then((webNovelOutlines) {
        emit(state.copyWith(webMostVisited: webNovelOutlines));
        newWebOutlines.addAll(webNovelOutlines);
      }),
      loadPagedWenkuOutline(level: 1).then((wenkuNovelOutlines) =>
          emit(state.copyWith(wenkuLatestUpdate: wenkuNovelOutlines))),
    ]);
    var webNovelOutlineMapSnapshot = {...state.webNovelOutlineMap};
    for (var webNovelOutline in newWebOutlines) {
      final novelKey =
          '${webNovelOutline.providerId}${webNovelOutline.novelId}';
      webNovelOutlineMapSnapshot[novelKey] = webNovelOutline;
    }
    emit(state.copyWith(
        inInit: false, webNovelOutlineMap: webNovelOutlineMapSnapshot));
  }

  _onRefreshFavoredWeb(
      _RefreshFavoredWeb event, Emitter<WebHomeState> emit) async {
    final webNovelOutlines = await loadFavoredWebOutline();
    var favoredWebMapSnapshot = <String, WebNovelOutline>{};
    for (var webNovelOutline in webNovelOutlines) {
      favoredWebMapSnapshot[
              '${webNovelOutline.providerId}${webNovelOutline.novelId}'] =
          webNovelOutline;
    }
    emit(state.copyWith(favoredWebMap: favoredWebMapSnapshot));
  }

  _onToNovelDetail(_ToNovelDetail event, Emitter<WebHomeState> emit) async {
    // 检查是否有缓存
    final existDto =
        state.webNovelDtoMap['${event.providerId}${event.novelId}'];
    if (existDto != null) {
      emit(state.copyWith(
        currentNovelId: event.novelId,
        currentNovelProviderId: event.providerId,
        currentWebNovelDto: existDto,
      ));
      return;
    }
    // 没有缓存，则请求
    emit(state.copyWith(
      loadingNovelDetail: true,
      currentNovelId: event.novelId,
      currentNovelProviderId: event.providerId,
    ));
    final response = await apiClient.webNovelService
        .getNovelId(event.providerId, event.novelId);
    if (response.statusCode == 502) {
      emit(state.copyWith(
        loadingNovelDetail: false,
      ));
      Fluttertoast.showToast(msg: '服务器维护中');
      return [];
    }
    final body = response.body;
    try {
      final key = event.providerId + event.novelId;

      final webNovelDto = WebNovelDto(
        body['titleJp'],
        attentions: body['attentions'].cast<String>(),
        authors: parseToAuthorList(body['authors']),
        baidu: body['baidu'],
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

      emit(state.copyWith(
        loadingNovelDetail: false,
        webNovelDtoMap: {...state.webNovelDtoMap, key: webNovelDto},
        currentWebNovelDto: webNovelDto,
      ));
      _updateLastReadChapterId(webNovelDto.lastReadChapterId);
    } catch (e) {
      talker.error(e);
    }
  }

  _onReadChapter(_ReadChapter event, Emitter<WebHomeState> emit) async {
    if (loadingChapter) return;

    var targetChapterId = event.chapterId;
    targetChapterId ??= findChapterId(state.currentWebNovelDto!);
    _updateLastReadChapterId(targetChapterId);
    globalBloc.add(const GlobalEvent.setReadType(ReadType.web));
    emit(state.copyWith(loadingNovelChapter: true));
    final chapterKey = currentNovelKey + targetChapterId;

    final targetDto = await _loadNovelChapter(
      currentNovelProviderId ?? '',
      currentNovelId ?? '',
      targetChapterId,
    );

    if (targetDto == null) throw Exception('targetDto is null');

    emit(state.copyWith(
      loadingNovelChapter: false,
      currentChapterDto: targetDto,
    ));
    final nextChapterKey = currentNovelKey + (targetDto.nextId ?? '');
    final nextDto = await _loadNovelChapter(
      currentNovelProviderId ?? '',
      currentNovelId ?? '',
      targetDto.nextId,
    );
    var dtoMapSnapshot = <String, ChapterDto?>{
      ...state.chapterDtoMap,
      chapterKey: targetDto,
      nextChapterKey: nextDto,
    };

    emit(state.copyWith(
      chapterDtoMap: dtoMapSnapshot,
    ));
  }

  _onNextChapter(_NextChapter event, Emitter<WebHomeState> emit) async {
    final nextId = state.currentChapterDto?.nextId;
    if (nextId == null) return;
    add(WebHomeEvent.readChapter(nextId));
  }

  _onPreviousChapter(_PreviousChapter event, Emitter<WebHomeState> emit) async {
    final prevId = state.currentChapterDto?.previousId;
    if (prevId == null) return;
    add(WebHomeEvent.readChapter(prevId));
  }

  _onCloseNovel(_CloseNovel event, Emitter<WebHomeState> emit) {
    globalBloc.add(const GlobalEvent.setReadType(ReadType.none));
  }

  _onLeaveDetail(_LeaveDetail event, Emitter<WebHomeState> emit) {}

  _onFavorNovel(_FavorNovel event, Emitter<WebHomeState> emit) async {
    switch (event.type) {
      case NovelType.web:
        emit(await _favorWeb());
        break;
      default:
    }
  }

  _onUnFavorNovel(_UnFavorNovel event, Emitter<WebHomeState> emit) async {
    switch (event.type) {
      case NovelType.web:
        emit(await _unFavorWeb());
        break;
      default:
    }
  }

  void _updateLastReadChapterId(String? chapterId) =>
      webCacheCubit.updateLastReadChapter(
          state.currentNovelProviderId!, state.currentNovelId!, chapterId);

  Future<WebHomeState> _favorWeb() async {
    if (currentNovelId == null || currentNovelProviderId == null) return state;
    final response = await apiClient.userFavoredWebService
        .putNovelId(currentNovelProviderId!, currentNovelId!);

    if (response!.statusCode == 200) {
      var favoredWebSnapshot = {...state.favoredWebMap};
      final outlineCache = state.webNovelOutlineMap[currentNovelKey];
      if (outlineCache == null) return state;
      favoredWebSnapshot[currentNovelKey] = outlineCache;
      showSucceedToast('收藏成功');
      return state.copyWith(favoredWebMap: favoredWebSnapshot);
    }
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return state;
    }
    return state;
  }

  Future<WebHomeState> _unFavorWeb() async {
    if (currentNovelId == null || currentNovelProviderId == null) return state;
    final response = await apiClient.userFavoredWebService
        .deleteNovelId(currentNovelProviderId!, currentNovelId!);
    if (response!.statusCode == 200) {
      var favoredWebSnapshot = {...state.favoredWebMap};
      favoredWebSnapshot.remove(currentNovelKey);
      showSucceedToast('取消收藏成功');
      return state.copyWith(favoredWebMap: favoredWebSnapshot);
    }
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return state;
    }
    return state;
  }

  /// 加载章节 (章节 dto, 是否为缓存)
  Future<ChapterDto?> _loadNovelChapter(
    String providerId,
    String novelId,
    String? chapterId,
  ) async {
    if (chapterId == null) return null;
    final chapterKey = providerId + novelId + chapterId;

    // 检查是否有缓存
    final existDto = state.chapterDtoMap[chapterKey];
    if (existDto != null) {
      return existDto;
    }

    // 没有缓存，则请求
    final chapterDto = await requestNovelChapter(
      providerId,
      novelId,
      chapterId,
    );
    return chapterDto;
  }

  bool get loadingChapter => state.loadingNovelChapter;
  String? get currentNovelId => state.currentNovelId;
  String? get currentNovelProviderId => state.currentNovelProviderId;
  String get currentNovelKey =>
      (state.currentNovelProviderId ?? '') + (state.currentNovelId ?? '');
}
