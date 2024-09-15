import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
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
        setWenkuLatestUpdate: (event) async =>
            await _onSetWenkuLatestUpdate(event, emit),
        setWenkuNovelOutlines: (event) async =>
            await _onSetWenkuNovelOutlines(event, emit),
        setLoadingStatus: (event) async =>
            await _onSetLoadingStatus(event, emit),
        toWenkuDetail: (event) async => await _onToWenkuDetail(event, emit),
        favorNovel: (event) async => await _onFavorNovel(event, emit),
        unFavorNovel: (event) async => await _onUnFavorNovel(event, emit),
        setSearchData: (event) async => await _onSetSearchData(event, emit),
      );
    });
  }

  _onSetWenkuLatestUpdate(
      _SetWenkuLatestUpdate event, Emitter<WenkuHomeState> emit) async {
    final wenkuList = event.wenkuNovelOutlines;
    emit(
      state.copyWith(wenkuLatestUpdate: wenkuList),
    );
    // TODO 移动到 Favored Cubit
    var favoredMap = <String, WenkuNovelOutline>{};
    for (var outline in wenkuList) {
      if (outline.favored != null) {
        favoredMap[outline.favored!] = outline;
      }
    }
  }

  _onSetWenkuNovelOutlines(
      _SetWenkuNovelOutlines event, Emitter<WenkuHomeState> emit) async {
    final wenkuList = event.wenkuNovelOutlines;
    var outlineMap = <String, WenkuNovelOutline>{};
    for (var outline in wenkuList) {
      outlineMap[outline.id] = outline;
    }
    emit(
      state.copyWith(
          wenkuNovelSearchResult: wenkuList,
          wenkuNovelOutlineMap: {...state.wenkuNovelOutlineMap, ...outlineMap}),
    );
    // TODO 移动到 Favored Cubit
    var favoredMap = <String, WenkuNovelOutline>{};
    for (var outline in wenkuList) {
      if (outline.favored != null) {
        favoredMap[outline.favored!] = outline;
      }
    }
  }

  _onToWenkuDetail(_ToWenkuDetail event, Emitter<WenkuHomeState> emit) async {
    add(const WenkuHomeEvent.setLoadingStatus({
      RequestLabel.loadNovelDetail: LoadingStatus.loading,
    }));
    var novelId = event.wenkuId;
    late final WenkuNovelDto novelDto;
    try {
      novelDto = await loadWenkuNovelDto(novelId) as WenkuNovelDto;
      emit(state.copyWith(
        wenkuNovelDtoMap: {
          ...state.wenkuNovelDtoMap,
          novelId: novelDto,
        },
        currentWenkuNovelDto: novelDto,
      ));
      add(const WenkuHomeEvent.setLoadingStatus({
        RequestLabel.loadNovelDetail: null,
      }));
    } catch (e) {
      add(WenkuHomeEvent.setLoadingStatus({
        RequestLabel.loadNovelDetail: (e is ServerException)
            ? LoadingStatus.serverError
            : LoadingStatus.failed,
      }));
    }
  }

  _onFavorNovel(_FavorNovel event, Emitter<WenkuHomeState> emit) async {
    if (currentNovelFavored(event.novelId)) return state;
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
    favoredCubit.setNovelToFavoredIdMap(
        simpleFavored: (state.currentWenkuNovelDto!.id, event.favoredId));

    showSucceedToast('收藏成功');
  }

  _onUnFavorNovel(_UnFavorNovel event, Emitter<WenkuHomeState> emit) async {
    if (!currentNovelFavored(event.novelId)) return;
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

  bool currentNovelFavored(String novelId) =>
      favoredCubit.state.novelToFavoredIdMap[novelId] != null;

  _onSetLoadingStatus(
      _SetSetLoadingStatus event, Emitter<WenkuHomeState> emit) {
    emit(state.copyWith(loadingStatusMap: {
      ...state.loadingStatusMap,
      ...event.loadingStatusMap,
    }));
  }

  _onSetSearchData(_SetSearchData event, Emitter<WenkuHomeState> emit) {
    emit(state.copyWith(wenkuSearchData: event.data));
  }

  String get currentNovelId => state.currentWenkuNovelDto?.id ?? '';

  bool get isSearchingWenku =>
      state.loadingStatusMap[RequestLabel.searchWenku] == LoadingStatus.loading;

  WenkuSearchData get searchData => state.wenkuSearchData;
}
