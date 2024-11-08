import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
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
        setWebNovelOutlines: (event) async =>
            await _onSetWebNovelOutlines(event, emit),
        setWebMostVisited: (event) async =>
            await _onSetWebMostVisited(event, emit),
        setLoadingStatus: (event) async =>
            await _onSetLoadingStatus(event, emit),
        setWebFavored: (event) async => await _onSetWebFavored(event, emit),
        toNovelDetail: (event) async => await _onToNovelDetail(event, emit),
        readChapter: (event) async => await _onReadChapter(event, emit),
        nextChapter: (event) async => await _onNextChapter(event, emit),
        previousChapter: (event) async => await _onPreviousChapter(event, emit),
        closeNovel: (event) async => await _onCloseNovel(event, emit),
        leaveDetail: (event) async => await _onLeaveDetail(event, emit),
        favorNovel: (event) async => await _onFavorNovel(event, emit),
        unFavorNovel: (event) async => await _onUnFavorNovel(event, emit),
        setSearchData: (event) async => await _onSetSearchData(event, emit),
        searchWeb: (event) async => await _onSearchWeb(event, emit),
        loadNextPageWeb: (event) async => await _onLoadNextPageWeb(event, emit),
      );
    });
  }

  _onSetWebMostVisited(
      _SetWebMostVisited event, Emitter<WebHomeState> emit) async {
    Set<WebNovelOutline> newWebOutlines = {};
    emit(state.copyWith(webMostVisited: event.webMostVisited));
    newWebOutlines.addAll(event.webMostVisited);
    _updateWebOutlinesCache(event.webMostVisited, emit);
  }

  _onSetWebFavored(_SetWebFavored event, Emitter<WebHomeState> emit) async {
    final webNovelOutlines = event.webFavored;
    // TODO 迁移到 FavoredCubit
    var favoredWebMapSnapshot = <String, WebNovelOutline>{};
    for (var webNovelOutline in webNovelOutlines) {
      favoredWebMapSnapshot[
              '${webNovelOutline.providerId}${webNovelOutline.novelId}'] =
          webNovelOutline;
    }
    emit(state.copyWith(favoredWebMap: favoredWebMapSnapshot));
  }

  _onToNovelDetail(_ToNovelDetail event, Emitter<WebHomeState> emit) async {
    add(const WebHomeEvent.setLoadingStatus({
      RequestLabel.loadNovelDetail: LoadingStatus.loading,
    }));
    late final WebNovelDto dto;
    try {
      dto = await loadWebNovelDto(
        event.providerId,
        event.novelId,
        onRequest: () => {},
        onRequestFinished: () => {},
      ) as WebNovelDto;
    } catch (e) {
      add(WebHomeEvent.setLoadingStatus({
        RequestLabel.loadNovelDetail: (e is ServerException)
            ? LoadingStatus.serverError
            : LoadingStatus.failed,
      }));
      return;
    }
    emit(state.copyWith(
      currentWebNovelDto: dto,
      webNovelDtoMap: {
        ...state.webNovelDtoMap,
        dto.novelKey: dto,
      },
      chapterDtoMap: {},
    ));
    if (webCacheCubit.state.lastReadChapterMap[dto.novelKey] == null) {
      _updateLastReadChapterId(
        dto.novelKey,
        dto.lastReadChapterId,
      );
    }
    add(const WebHomeEvent.setLoadingStatus({
      RequestLabel.loadNovelDetail: null,
    }));
  }

  _onReadChapter(_ReadChapter event, Emitter<WebHomeState> emit) async {
    if (loadingChapter) return;
    var targetChapterId = event.chapterId;
    targetChapterId ??= findChapterId(state.currentWebNovelDto!);
    final dto = state.currentWebNovelDto!;
    _updateLastReadChapterId(dto.novelKey, targetChapterId);
    globalBloc.add(const GlobalEvent.setReadType(ReadType.web));
    emit(state.copyWith(loadingNovelChapter: true));
    final chapterKey = '${currentNovelKey!}-$targetChapterId';

    final targetDto = await loadNovelChapter(
      currentNovelProviderId,
      currentNovelId,
      targetChapterId,
      onRequest: () => emit(state.copyWith(loadingNovelChapter: true)),
      onRequestFinished: () => emit(state.copyWith(
        loadingNovelChapter: false,
      )),
    );

    if (targetDto == null) throw Exception('targetDto is null');

    emit(state.copyWith(
      loadingNovelChapter: false,
      currentChapterDto: targetDto,
    ));
    _requestUpdateReadHistory(
        currentNovelProviderId, currentNovelId, targetChapterId);

    var dtoMapSnapshot = <String, ChapterDto?>{
      ...state.chapterDtoMap,
      chapterKey: targetDto,
    };
    // 预加载下一章节
    if (targetDto.nextId != null) {
      final nextChapterKey = '${currentNovelKey!}-${targetDto.nextId ?? ''}';
      final nextDto = await loadNovelChapter(
        currentNovelProviderId,
        currentNovelId,
        targetDto.nextId,
      );
      dtoMapSnapshot[nextChapterKey] = nextDto;
    }
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
        emit(await _favorWeb(event.favoredId));
        break;
      default:
    }
  }

  _onUnFavorNovel(_UnFavorNovel event, Emitter<WebHomeState> emit) async {
    switch (event.type) {
      case NovelType.web:
        emit(await _unFavorWeb(event.favoredId));
        break;
      default:
    }
  }

  _onSetSearchData(_SetSearchData event, Emitter<WebHomeState> emit) {
    emit(state.copyWith(webSearchData: event.data));
  }

  _onSearchWeb(_SearchWeb event, Emitter<WebHomeState> emit) async {
    if (state.searchingWeb) return;
    final data = state.webSearchData;
    emit(state.copyWith(
      searchingWeb: true,
      webNovelSearchResult: [],
      currentWebSearchPage: 0,
      webProvider: data.provider.map((e) => e.name).toList(),
      webType: NovelStatus.indexByZhName(data.type.zhName),
      webLevel: WebNovelLevel.indexByZhName(data.level.zhName),
      webTranslate: WebTranslationSource.indexByZhName(data.translate.zhName),
      webSort: WebNovelOrder.indexByZhName(data.sort.zhName),
      webQuery: data.query,
    ));
    await _loadPagedWebNovel(emit);
  }

  _onLoadNextPageWeb(_LoadNextPageWeb event, Emitter<WebHomeState> emit) async {
    if (state.searchingWeb) return;
    if (state.currentWebSearchPage == state.maxPage) {
      showWarnToast('一点都没有啦~');
      return;
    }
    if (state.currentWebSearchPage >= state.maxPage) return;
    emit(state.copyWith(
      currentWebSearchPage: state.currentWebSearchPage + 1,
      searchingWeb: true,
    ));
    await _loadPagedWebNovel(emit);
  }

  void _updateWebOutlinesCache(
      List<WebNovelOutline> outlines, Emitter<WebHomeState> emit) async {
    var webNovelOutlineMapSnapshot = {...state.webNovelOutlineMap};
    for (var webNovelOutline in outlines) {
      webNovelOutlineMapSnapshot[webNovelOutline.novelId] = webNovelOutline;
    }
    emit(state.copyWith(
      webNovelOutlineMap: webNovelOutlineMapSnapshot,
    ));
  }

  Future<void> _loadPagedWebNovel(Emitter<WebHomeState> emit) async {
    final (newNovelList, pageNumber) = await loadPagedWebOutline(
      page: state.currentWebSearchPage,
      pageSize: 20,
      provider: state.webProvider.join(','),
      type: state.webType,
      level: state.webLevel,
      translate: state.webTranslate,
      sort: state.webSort,
      query: state.webQuery,
    );
    emit(state.copyWith(
      webNovelSearchResult: [
        ...state.webNovelSearchResult,
        ...newNovelList,
      ],
      searchingWeb: false,
      maxPage: pageNumber,
    ));
  }

  void _updateLastReadChapterId(String novelKey, String? chapterId) =>
      webCacheCubit.updateLastReadChapter(novelKey, chapterId);

  Future<WebHomeState> _favorWeb(String favoredId) async {
    final response = await apiClient.userFavoredWebService.putNovelId(
        currentNovelProviderId, currentNovelId,
        favoredId: favoredId);

    if (response!.statusCode == 200) {
      favoredCubit
          .setNovelToFavoredIdMap(simpleFavored: (currentNovelId, favoredId));
      showSucceedToast('收藏成功');

      favoredCubit
          .setNovelToFavoredIdMap(simpleFavored: (currentNovelId, favoredId));
    }
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return state;
    }
    return state;
  }

  Future<WebHomeState> _unFavorWeb(String favoredId) async {
    final response = await apiClient.userFavoredWebService
        .deleteNovelId(currentNovelProviderId, currentNovelId);
    if (response!.statusCode == 200) {
      var favoredWebSnapshot = {...state.favoredWebMap};
      favoredWebSnapshot.remove(currentNovelKey);
      showSucceedToast('取消收藏成功');
      favoredCubit.unFavor(
          type: NovelType.web, favoredId: favoredId, novelId: currentNovelId);
      return state.copyWith(favoredWebMap: favoredWebSnapshot);
    }
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return state;
    }
    return state;
  }

  Future<void> _requestUpdateReadHistory(
      String providerId, String novelId, String chapterId) async {
    apiClient.userReadHistoryWebService
        .putNovelId(providerId, novelId, chapterId);
  }

  _onSetLoadingStatus(_SetLoadingStatus event, Emitter<WebHomeState> emit) {
    emit(state.copyWith(loadingStatusMap: {
      ...state.loadingStatusMap,
      ...event.loadingStatusMap,
    }));
  }

  _onSetWebNovelOutlines(
      _SetWebNovelOutlines event, Emitter<WebHomeState> emit) {
    emit(state.copyWith(
      webNovelSearchResult: event.webOutlines,
    ));
  }

  bool get loadingChapter => state.loadingNovelChapter;
  String get currentNovelId => state.currentWebNovelDto!.novelId;
  String get currentNovelProviderId => state.currentWebNovelDto!.providerId;
  String? get currentNovelKey => state.currentWebNovelDto?.novelKey;

  WebSearchData get searchData => state.webSearchData;
}
