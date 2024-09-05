import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wenku_home_event.dart';
part 'wenku_home_state.dart';
part 'wenku_home_bloc.freezed.dart';

class WenkuHomeBloc extends Bloc<WenkuHomeEvent, WenkuHomeState> {
  WenkuHomeBloc() : super(const _Initial()) {
    on<WenkuHomeEvent>((event, emit) async {
      await event.map(
        init: (event) async => await _onInit(event, emit),
        toDetail: (event) async => await _onToDetail(event, emit),
        favorNovel: (event) async => await _onFavorNovel(event, emit),
        unFavorNovel: (event) async => await _onUnFavorNovel(event, emit),
        searchWenku: (event) async => await _onSearchWenku(event, emit),
        loadNextPageWenku: (event) async =>
            await _onLoadNextPageWenku(event, emit),
      );
    });
  }

  _onInit(_Init event, Emitter<WenkuHomeState> emit) async {
    await loadPagedWenkuOutline(level: 1).then((wenkuNovelOutlinesResult) {
      emit(
        state.copyWith(wenkuLatestUpdate: wenkuNovelOutlinesResult.$1),
      );
      var favoredMap = <String, WenkuNovelOutline>{};
      for (var outline in wenkuNovelOutlinesResult.$1) {
        if (outline.favored != null) {
          favoredMap[outline.favored!] = outline;
        }
      }
    });
  }

  _onToDetail(_ToDetail event, Emitter<WenkuHomeState> emit) async {
    var novelId = event.wenkuNovel.id;
    emit(state.copyWith(currentNovelId: novelId));
    final novelDto = await loadWenkuNovelDto(
      novelId,
      onRequest: () => emit(state.copyWith(loadingDetail: true)),
      onRequestFinished: () => emit(state.copyWith(loadingDetail: false)),
    );
    if (novelDto == null) return;
    emit(state.copyWith(
      wenkuNovelDtoMap: {
        ...state.wenkuNovelDtoMap,
        novelId: novelDto,
      },
      currentWenkuNovelOutline: event.wenkuNovel,
      currentWenkuNovelDto: novelDto,
    ));
  }

  _onFavorNovel(_FavorNovel event, Emitter<WenkuHomeState> emit) async {
    if (currentNovelFavored) return state;
    final response = await apiClient.userFavoredWenkuService.putNovelId(
      event.favoredId,
      event.novelId,
    );
    if (response == null) return;
    if (response.statusCode != 200) {
      showErrorToast('收藏失败');
    }
    final wenkuNovelDto = state.wenkuNovelDtoMap[event.novelId]?.copyWith(
      favored: event.favoredId,
    );
    if (wenkuNovelDto == null) throw Exception('wenkuNovelDto is null');
    emit(state.copyWith(
      favoredWenkuMap: {
        ...state.favoredWenkuMap,
        event.novelId: true,
      },
      wenkuNovelDtoMap: {
        ...state.wenkuNovelDtoMap,
        event.novelId: wenkuNovelDto,
      },
    ));
    favoredCubit.favor(
      favoredId: event.favoredId,
      type: NovelType.wenku,
      wenkuOutline: state.currentWenkuNovelOutline,
    );
    showSucceedToast('收藏成功');
  }

  _onUnFavorNovel(_UnFavorNovel event, Emitter<WenkuHomeState> emit) async {
    if (!currentNovelFavored) return;
    final response = await apiClient.userFavoredWenkuService.delNovelId(
      event.favoredId,
      event.novelId,
    );
    if (response == null) return;

    if (response.statusCode != 200) {
      showErrorToast('收藏失败');
    }

    final wenkuNovelDto = state.wenkuNovelDtoMap[event.novelId];
    if (wenkuNovelDto == null) throw Exception('wenkuNovelDto is null');
    final unfavoredWenkuNovelDto = wenkuNovelDto.copyWith(
      favored: '',
    );
    favoredCubit.unFavor(
        type: NovelType.wenku,
        favoredId: event.favoredId,
        novelId: event.novelId);
    emit(state.copyWith(
      favoredWenkuMap: {
        ...state.favoredWenkuMap,
        event.novelId: false,
      },
      wenkuNovelDtoMap: {
        ...state.wenkuNovelDtoMap,
        event.novelId: unfavoredWenkuNovelDto,
      },
    ));
    showSucceedToast('取消收藏成功');
  }

  _onSearchWenku(_SearchWenku event, Emitter<WenkuHomeState> emit) async {
    if (state.searchingWenku) return;
    emit(state.copyWith(
      searchingWenku: true,
      wenkuNovelSearchResult: [],
      currentWenkuSearchPage: 0,
      wenkuLevel: event.level,
      wenkuQuery: event.query,
    ));
    await _loadPagedWenkuNovel(emit);
  }

  _onLoadNextPageWenku(
      _LoadNextPageWenku event, Emitter<WenkuHomeState> emit) async {
    if (state.searchingWenku) return;
    if (state.currentWenkuSearchPage == state.maxPage) {
      showWarnToast('一点都没有啦~');
      return;
    }
    if (state.currentWenkuSearchPage >= state.maxPage) return;
    emit(state.copyWith(
      currentWenkuSearchPage: state.currentWenkuSearchPage + 1,
      searchingWenku: true,
    ));
    await _loadPagedWenkuNovel(emit);
  }

  Future<void> _loadPagedWenkuNovel(Emitter<WenkuHomeState> emit) async {
    final (newNovelList, pageNumber) = await loadPagedWenkuOutline(
      page: state.currentWenkuSearchPage,
      pageSize: 21,
      level: state.wenkuLevel,
      query: state.wenkuQuery,
    );
    var newWenkuNovelOutlineMap = {...state.wenkuNovelOutlineMap};
    for (var newNovel in newNovelList) {
      newWenkuNovelOutlineMap[newNovel.id] = newNovel;
    }
    emit(state.copyWith(
        wenkuNovelSearchResult: [
          ...state.wenkuNovelSearchResult,
          ...newNovelList
        ],
        searchingWenku: false,
        maxPage: pageNumber,
        wenkuNovelOutlineMap: {
          ...state.wenkuNovelOutlineMap,
          ...newWenkuNovelOutlineMap,
        }));
  }

  bool get currentNovelFavored =>
      state.currentWenkuNovelOutline?.favored?.isNotEmpty ?? false;
}
