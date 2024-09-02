import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
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
        jumpToChapter: (event) async => await _onJumpToChapter(event, emit),
        closeNovel: (event) async => await _onCloseNovel(event, emit),
        leaveDetail: (event) async => await _onLeaveDetail(event, emit),
      );
    });
  }

  _onInit(_Init event, Emitter<WebHomeState> emit) async {
    if (state.inInit) return;
    emit(state.copyWith(inInit: true));
    await Future.wait([
      refreshFavoredWeb().then(
        (webNovelOutlines) => emit(
          state.copyWith(favoredWeb: webNovelOutlines),
        ),
      ),
      apiClient.webNovelService
          .getList(
        0,
        8,
        provider: 'kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis',
        sort: 1,
        level: 1,
      )
          .then((response) {
        final body = response.body;
        final webNovelOutlines = parseToWebNovelOutline(body);
        emit(state.copyWith(webMostVisited: webNovelOutlines));
      }),
      apiClient.wenkuNovelService
          .getList(
        0,
        12,
        level: 1,
      )
          .then((response) {
        final body = response.body;
        final wenkuNovelOutlines = parseToWenkuNovelOutline(body);
        emit(state.copyWith(wenkuLatestUpdate: wenkuNovelOutlines));
      }),
    ]);
    emit(state.copyWith(inInit: false));
  }

  Future<List<WebNovelOutline>> refreshFavoredWeb() async {
    return apiClient.userFavoredWebService
        .getIdList(
      'default',
      0,
      8,
      SearchSortType.update.name,
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

  _onRefreshFavoredWeb(
      _RefreshFavoredWeb event, Emitter<WebHomeState> emit) async {
    final webNovelOutlines = await refreshFavoredWeb();
    emit(state.copyWith(favoredWeb: webNovelOutlines));
  }

  _onToNovelDetail(_ToNovelDetail event, Emitter<WebHomeState> emit) async {
    final existDto =
        state.webNovelDtoMap['${event.providerId}${event.novelId}'];
    if (existDto != null) {
      emit(state.copyWith(
        currentNovelId: event.novelId,
        currentNovelProviderId: event.providerId,
        currentWebNovelDto: existDto,
        currentChapterIndex: existDto.lastReadChapterId,
      ));
      return;
    }

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
        currentChapterIndex: _findChapterId(webNovelDto),
      ));
    } catch (e) {
      talker.error(e);
    }
  }

  _onReadChapter(_ReadChapter event, Emitter<WebHomeState> emit) async {
    globalBloc.add(const GlobalEvent.setReadType(ReadType.web));
    emit(state.copyWith(loadingNovelChapter: true));
    final targetChapterId = state.currentChapterIndex ?? '';
    final providerId = state.currentNovelProviderId ?? '';
    final novelId = state.currentNovelId ?? '';
    final chapterKey = providerId + novelId + targetChapterId;
    final existDto = state.chapterDtoMap[chapterKey];
    if (existDto != null) {
      emit(
        state.copyWith(
          loadingNovelChapter: false,
          currentChapterDto: existDto,
          currentChapterIndex: targetChapterId,
        ),
      );
      return;
    }

    final chapterDto = await requestNovelChapter(
      providerId,
      novelId,
      targetChapterId,
    );
    if (chapterDto != null) {
      emit(state.copyWith(
        chapterDtoMap: {...state.chapterDtoMap, chapterKey: chapterDto},
        currentChapterDto: chapterDto,
        currentChapterIndex: targetChapterId,
      ));
    }
    emit(state.copyWith(loadingNovelChapter: false));
  }

  String _findChapterId(WebNovelDto webNovelDto) {
    final tocList = webNovelDto.toc;
    String? targetChapterId;
    if (tocList == null) {
      targetChapterId = '0';
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
      targetChapterId = '1';
    }
    return targetChapterId;
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

  _onNextChapter(_NextChapter event, Emitter<WebHomeState> emit) async {
    if (state.currentChapterDto?.nextId == null) return;
    emit(state.copyWith(currentChapterIndex: state.currentChapterDto?.nextId));
    add(const WebHomeEvent.readChapter());
  }

  _onPreviousChapter(_PreviousChapter event, Emitter<WebHomeState> emit) async {
    if (state.currentChapterDto?.previousId == null) return;
    emit(state.copyWith(
        currentChapterIndex: state.currentChapterDto?.previousId));
    add(const WebHomeEvent.readChapter());
  }

  _onJumpToChapter(_JumpToChapter event, Emitter<WebHomeState> emit) async {
    emit(state.copyWith(currentChapterIndex: event.index));
    add(const WebHomeEvent.readChapter());
  }

  _onCloseNovel(_CloseNovel event, Emitter<WebHomeState> emit) {
    globalBloc.add(const GlobalEvent.setReadType(ReadType.none));
  }

  _onLeaveDetail(_LeaveDetail event, Emitter<WebHomeState> emit) {
    final novelDtoMapSnapshot = {...state.webNovelDtoMap};
    final updatedCurrentNovelDto = state.currentWebNovelDto?.copyWith(
      lastReadChapterId: state.currentChapterIndex,
    );
    if (updatedCurrentNovelDto != null) {
      novelDtoMapSnapshot[(state.currentNovelProviderId ?? '') +
          (state.currentNovelId ?? '')] = updatedCurrentNovelDto;
      emit(state.copyWith(webNovelDtoMap: novelDtoMapSnapshot));
    }
  }
}
