import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'novel_rank_event.dart';
part 'novel_rank_state.dart';
part 'novel_rank_bloc.freezed.dart';

class NovelRankBloc extends Bloc<NovelRankEvent, NovelRankState> {
  NovelRankBloc() : super(const _Initial()) {
    on<NovelRankEvent>((event, emit) async {
      await event.map(
        searchRankNovel: (event) async => await _onSearchRankNovel(event, emit),
        loadNextPageRankNovel: (event) async =>
            await _onLoadNextPageRankNovel(event, emit),
      );
    });
  }

  _onSearchRankNovel(
      _SearchRankNovel event, Emitter<NovelRankState> emit) async {
    if (state.searchingStatus[event.rankCategory] == true) return;

    emit(state.copyWith(
      currentPage: {...state.currentPage, event.rankCategory: 0},
    ));
    try {
      await _requestByRankCategory(event.rankCategory, emit);
    } catch (e) {
      talker.error(e);
      emit(state.copyWith(
        searchingStatus: {...state.searchingStatus, event.rankCategory: false},
      ));
    }
  }

  _onLoadNextPageRankNovel(
      _LoadNextPageRankNovel event, Emitter<NovelRankState> emit) async {
    showErrorToast('没有更多数据了啦');
    // if (state.searchingStatus[event.rankCategory] == true) return;
    // emit(state.copyWith(
    //   currentPage: {
    //     ...state.currentPage,
    //     event.rankCategory: state.currentPage[event.rankCategory]! + 1
    //   },
    // ));
    // await _requestByRankCategory(event.rankCategory, emit);
  }

  Future<void> _requestByRankCategory(
      RankCategory rankCategory, Emitter<NovelRankState> emit) async {
    switch (rankCategory) {
      case RankCategory.syosetuGenre:
        await _loadSyosetuGenre(state.syosetuGenreSearchData.query, emit);
        break;
      case RankCategory.syosetuComprehensive:
        await _loadSyosetuComprehensive(
            state.syosetuComprehensiveSearchData.query, emit);
        break;
      case RankCategory.syosetuIsekai:
        await _loadSyosetuIsekai(state.syosetuIsekaiSearchData.query, emit);
        break;
      case RankCategory.kakuyomuGenre:
        await _loadKakuyomuGenre(state.kakuyomuGenreSearchData.query, emit);
        break;
      default:
    }
  }

  Future<void> _loadSyosetuGenre(
      Map<String, String> query, Emitter<NovelRankState> emit) async {
    emit(state.copyWith(
      searchingStatus: {
        ...state.searchingStatus,
        RankCategory.syosetuGenre: true
      },
    ));
    final response = await apiClient.webNovelService.getRank(
      'syosetu',
      {
        ...query,
        'page': (state.currentPage[RankCategory.syosetuGenre] ?? 0).toString()
      },
    );
    final body = response.body;
    final maxPage = body['pageNumber'];
    final newDtoList = parseToWebNovelOutline(body);
    _appendNovelList(RankCategory.syosetuGenre, newDtoList, maxPage, emit);
  }

  Future<void> _loadSyosetuComprehensive(
      Map<String, String> query, Emitter<NovelRankState> emit) async {
    emit(state.copyWith(
      searchingStatus: {
        ...state.searchingStatus,
        RankCategory.syosetuComprehensive: true
      },
    ));
    final response = await apiClient.webNovelService.getRank(
      'syosetu',
      {
        ...query,
        'page': (state.currentPage[RankCategory.syosetuComprehensive] ?? 0)
            .toString()
      },
    );
    final body = response.body;
    final maxPage = body['pageNumber'];
    final newDtoList = parseToWebNovelOutline(body);
    _appendNovelList(
        RankCategory.syosetuComprehensive, newDtoList, maxPage, emit);
  }

  Future<void> _loadSyosetuIsekai(
      Map<String, String> query, Emitter<NovelRankState> emit) async {
    emit(state.copyWith(
      searchingStatus: {
        ...state.searchingStatus,
        RankCategory.syosetuIsekai: true
      },
    ));
    final response = await apiClient.webNovelService.getRank(
      'syosetu',
      {
        ...query,
        'page': (state.currentPage[RankCategory.syosetuIsekai] ?? 0).toString()
      },
    );
    final body = response.body;
    final maxPage = body['pageNumber'];
    final newDtoList = parseToWebNovelOutline(body);
    _appendNovelList(RankCategory.syosetuIsekai, newDtoList, maxPage, emit);
  }

  Future<void> _loadKakuyomuGenre(
      Map<String, String> query, Emitter<NovelRankState> emit) async {
    emit(state.copyWith(
      searchingStatus: {
        ...state.searchingStatus,
        RankCategory.kakuyomuGenre: true
      },
    ));
    final response = await apiClient.webNovelService.getRank(
      'kakuyomu',
      {
        ...query,
        'page': (state.currentPage[RankCategory.kakuyomuGenre] ?? 0).toString()
      },
    );
    final body = response.body;
    final maxPage = body['pageNumber'];
    final newDtoList = parseToWebNovelOutline(body);
    _appendNovelList(RankCategory.kakuyomuGenre, newDtoList, maxPage, emit);
  }

  void _appendNovelList(
      RankCategory rankCategory,
      List<WebNovelOutline> newDtoList,
      int maxPage,
      Emitter<NovelRankState> emit) {
    final dtoList = [
      ...(state.novels[rankCategory] ?? <WebNovelOutline>[]),
      ...newDtoList
    ];
    emit(state.copyWith(
      novels: {...state.novels, rankCategory: dtoList},
      searchingStatus: {...state.searchingStatus, rankCategory: false},
      maxPage: {...state.maxPage, rankCategory: maxPage},
    ));
  }
}
