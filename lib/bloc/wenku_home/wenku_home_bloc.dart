import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
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
    await loadPagedWenkuOutline(level: 1).then(
      (wenkuNovelOutlinesResult) => emit(
        state.copyWith(wenkuLatestUpdate: wenkuNovelOutlinesResult.$1),
      ),
    );
  }

  _onToDetail(_ToDetail event, Emitter<WenkuHomeState> emit) async {
    var novelId = event.novelId;
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
      currentWenkuNovelDto: novelDto,
    ));
  }

  _onFavorNovel(_FavorNovel event, Emitter<WenkuHomeState> emit) async {
    // TODO
  }

  _onUnFavorNovel(_UnFavorNovel event, Emitter<WenkuHomeState> emit) async {
    // TODO
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
    emit(state.copyWith(
      wenkuNovelSearchResult: [
        ...state.wenkuNovelSearchResult,
        ...newNovelList
      ],
      searchingWenku: false,
      maxPage: pageNumber,
    ));
  }
}
