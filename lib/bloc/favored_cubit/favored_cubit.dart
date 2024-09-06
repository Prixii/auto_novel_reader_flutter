import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favored_state.dart';
part 'favored_cubit.freezed.dart';

class FavoredCubit extends Cubit<FavoredState> {
  FavoredCubit() : super(const FavoredState.initial());

  Future<void> init() async {
    if (!userCubit.isSignIn) {
      emit(state.copyWith(favoredMap: {
        NovelType.local: localFavored,
        NovelType.web: webFavored,
        NovelType.wenku: wenkuFavored
      }, currentFavored: Favored.createDefault(), currentType: NovelType.web));
      return;
    }
    emit(state.copyWith(favoredMap: {
      NovelType.local: localFavored,
      NovelType.web: webFavored,
      NovelType.wenku: wenkuFavored
    }, currentFavored: Favored.createDefault(), currentType: NovelType.web));
    // 向服务器获取
    final response = await apiClient.userService.getFavored();
    if (response?.statusCode == 502) {
      showErrorToast('服务器维护中');
      return;
    }
    final body = response?.body;
    emit(state.copyWith(
      favoredMap: {
        NovelType.local: localFavored,
        NovelType.web: parseToFavored(body['favoredWeb']),
        NovelType.wenku: parseToFavored(body['favoredWenku'])
      },
      currentFavored: Favored.createDefault(),
      currentType: NovelType.web,
    ));
    requestFavoredNovels();
  }

  List<Favored> parseToFavored(dynamic body) {
    var favoreds = <Favored>[];
    for (var item in body) {
      favoreds.add(Favored(id: item['id'], title: item['title']));
    }
    if (favoreds.isEmpty) favoreds.add(Favored.createDefault());
    return favoreds;
  }

  List<Favored> get localFavored => (state.favoredMap[NovelType.local]!.isEmpty)
      ? [Favored.createDefault()]
      : state.favoredMap[NovelType.local]!;

  List<Favored> get webFavored => (state.favoredMap[NovelType.web]!.isEmpty)
      ? [Favored.createDefault()]
      : state.favoredMap[NovelType.web]!;

  List<Favored> get wenkuFavored => (state.favoredMap[NovelType.wenku]!.isEmpty)
      ? [Favored.createDefault()]
      : state.favoredMap[NovelType.wenku]!;

  Future<void> loadNextPage() async {
    if (state.currentType == NovelType.web) {
      if (state.isWebRequestingMap[state.currentFavored?.id] == true) {
        return;
      }
      final oldValue = state.favoredWebPageMap[state.currentFavored?.id] ?? 0;
      if (oldValue + 1 >=
          state.favoredWebMaxPageMap[state.currentFavored?.id]!) {
        return;
      }
      emit(state.copyWith(favoredWebPageMap: {
        ...state.favoredWebPageMap,
        state.currentFavored!.id: oldValue + 1
      }));
    } else if (state.currentType == NovelType.wenku) {
      if (state.isWenkuRequestingMap[state.currentFavored?.id] == true) {
        return;
      }
      final oldValue = state.favoredWenkuPageMap[state.currentFavored?.id] ?? 0;
      if (oldValue + 1 >=
          state.favoredWenkuMaxPageMap[state.currentFavored?.id]!) return;
      emit(state.copyWith(favoredWenkuPageMap: {
        ...state.favoredWenkuPageMap,
        state.currentFavored!.id: oldValue + 1
      }));
    }
    requestFavoredNovels(refresh: false);
  }

  Future<void> setFavored({
    NovelType? type,
    Favored? favored,
  }) async {
    final novelType = type ?? state.currentType;
    if (type != null) {
      emit(state.copyWith(
          currentType: type, currentFavored: Favored.createDefault()));
    } else {
      emit(state.copyWith(
        currentType: novelType,
        currentFavored: favored ?? state.currentFavored,
      ));
    }
    late List? targetNovels;
    if (novelType == NovelType.web) {
      targetNovels = state.favoredWebNovelsMap[state.currentFavored?.id];
    } else if (novelType == NovelType.wenku) {
      targetNovels = state.favoredWenkuNovelsMap[state.currentFavored?.id];
    } else {
      throw Exception('invalid novel type');
    }
    if (targetNovels == null || targetNovels.isEmpty) {
      requestFavoredNovels();
    }
  }

  Future<void> requestFavoredNovels({
    SearchSortType sortType = SearchSortType.update,
    bool refresh = true,
  }) async {
    switch (state.currentType) {
      case NovelType.web:
        refresh
            ? await _requestWebFavored(state.currentFavored!.id, sortType)
            : await _loadWebFavored(state.currentFavored!.id, sortType);
        break;
      case NovelType.wenku:
        refresh
            ? await _requestWenkuFavored(state.currentFavored!.id, sortType)
            : await _loadWenkuFavored(state.currentFavored!.id, sortType);
        break;
      case NovelType.local:
        showWarnToast('暂不支持');
        break;
    }
  }

  Future<void> _requestWebFavored(
    String favoredId,
    SearchSortType sortType,
  ) async {
    if (state.isWebRequestingMap[favoredId] == true) return;
    emit(state.copyWith(
      favoredWebPageMap: {
        ...state.favoredWebPageMap,
        favoredId: 0,
      },
      favoredWebMaxPageMap: {
        ...state.favoredWebMaxPageMap,
        favoredId: 0,
      },
      favoredWebNovelsMap: {
        ...state.favoredWebNovelsMap,
        favoredId: [],
      },
    ));
    _loadWebFavored(favoredId, sortType, refresh: true);
  }

  Future<void> _requestWenkuFavored(
    String favoredId,
    SearchSortType sortType,
  ) async {
    if (state.isWenkuRequestingMap[favoredId] == true) return;
    emit(state.copyWith(
      favoredWenkuPageMap: {
        ...state.favoredWenkuPageMap,
        favoredId: 0,
      },
      favoredWenkuMaxPageMap: {
        ...state.favoredWenkuMaxPageMap,
        favoredId: 0,
      },
      favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favoredId: [],
      },
    ));
    _loadWenkuFavored(favoredId, sortType, refresh: true);
  }

  Future<void> _loadWebFavored(
    String favoredId,
    SearchSortType sortType, {
    bool refresh = false,
  }) async {
    // 设置请求标志
    emit(state.copyWith(isWebRequestingMap: {
      ...state.isWebRequestingMap,
      favoredId: true,
    }));
    try {
      // 发送请求
      final response = await apiClient.userFavoredWebService.getIdList(
        favoredId: favoredId,
        page: state.favoredWebPageMap[favoredId] ?? 0,
        pageSize: 20,
        sort: sortType.name,
      );
      if (response == null) throw Exception('response is null');
      if (response.statusCode == 502) {
        showErrorToast('服务器维护中');
        throw Exception('服务器维护中');
      }

      // 处理响应
      final body = response.body;
      final maxPage = body['pageNumber'];
      final newWebNovelList = parseToWebNovelOutline(body);
      emit(state.copyWith(
        favoredWebMaxPageMap: {
          ...state.favoredWebMaxPageMap,
          favoredId: maxPage,
        },
        favoredWebNovelsMap: {
          ...state.favoredWebNovelsMap,
          favoredId: [
            ...(refresh ? [] : (state.favoredWebNovelsMap[favoredId] ?? [])),
            ...newWebNovelList
          ],
        },
        isWebRequestingMap: {
          ...state.isWebRequestingMap,
          favoredId: false,
        },
      ));
      setNovelToFavoredIdMap(webOutlines: newWebNovelList);
    } catch (e, stacktrace) {
      talker.error('error', e, stacktrace);
      emit(state.copyWith(isWebRequestingMap: {
        ...state.isWebRequestingMap,
        favoredId: false,
      }));
    }
  }

  Future<void> _loadWenkuFavored(
    String favoredId,
    SearchSortType sortType, {
    bool refresh = false,
  }) async {
    emit(state.copyWith(isWenkuRequestingMap: {
      ...state.isWenkuRequestingMap,
      favoredId: true,
    }));
    // 发送请求
    await apiClient.userFavoredWenkuService
        .getIdList(
      favoredId: favoredId,
      page: state.favoredWenkuPageMap[favoredId] ?? 0,
      pageSize: 20,
      sort: sortType.name,
    )
        .then((response) {
      if (response == null) {
        throw Exception('response is null');
      }
      if (response.statusCode == 502) {
        showErrorToast('服务器维护中');
        throw Exception('服务器维护中');
      }
      // 处理响应
      final body = response.body;
      final maxPage = body['pageNumber'];
      final newWenkuNovelList = parseToWenkuNovelOutline(body);
      emit(state.copyWith(favoredWenkuMaxPageMap: {
        ...state.favoredWenkuMaxPageMap,
        favoredId: maxPage,
      }, favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favoredId: [
          ...(refresh ? [] : (state.favoredWenkuNovelsMap[favoredId] ?? [])),
          ...newWenkuNovelList
        ],
      }, isWenkuRequestingMap: {
        ...state.isWenkuRequestingMap,
      }));
      setNovelToFavoredIdMap(wenkuOutlines: newWenkuNovelList);
    }).catchError((e, stacktrace) {
      talker.error('error', e, stacktrace);
      emit(state.copyWith(isWenkuRequestingMap: {
        ...state.isWenkuRequestingMap,
        favoredId: false,
      }));
    });
  }

  void updateFavorState(
    String favoredId,
    List<WenkuNovelOutline>? wenkuNovelOutlines,
    List<WebNovelOutline>? webNovelOutlines,
  ) {
    if (wenkuNovelOutlines != null) {
      emit(state.copyWith(favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favoredId: wenkuNovelOutlines,
      }));
    } else {
      emit(state.copyWith(favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favoredId: <WenkuNovelOutline>[],
      }));
    }
  }

  void unFavor({
    required NovelType type,
    required String favoredId,
    required String novelId,
  }) async {
    if (type == NovelType.web) {
      final outlineListSnapshot = state.favoredWebNovelsMap[favoredId];
      emit(state.copyWith(
        favoredWebNovelsMap: {
          ...state.favoredWebNovelsMap,
          favoredId: [
            ...outlineListSnapshot!
                .where((element) => element.novelId != novelId),
          ]
        },
        novelToFavoredIdMap: {...state.novelToFavoredIdMap}..removeWhere(
            (key, value) => key == novelId,
          ),
      ));
    } else if (type == NovelType.wenku) {
      final outlineListSnapshot = state.favoredWenkuNovelsMap[favoredId];
      emit(state.copyWith(
        favoredWenkuNovelsMap: {
          ...state.favoredWenkuNovelsMap,
          favoredId: [
            ...outlineListSnapshot?.where((element) => element.id != novelId) ??
                [],
          ],
        },
        novelToFavoredIdMap: {...state.novelToFavoredIdMap}..removeWhere(
            (key, value) => key == novelId,
          ),
      ));
    }
  }

  void setNovelToFavoredIdMap({
    List<WebNovelOutline>? webOutlines,
    List<WenkuNovelOutline>? wenkuOutlines,
    (String, WebNovelDto)? webNovelDtoData,
    (String, WenkuNovelDto)? wenkuNovelDtoData,
    (String, String?)? simpleFavored,
  }) {
    var newFavoredMap = <String, String>{};
    if (webOutlines != null) {
      for (var webOutline in webOutlines) {
        if (webOutline.favored != null) {
          newFavoredMap[webOutline.novelId] = webOutline.favored!;
        }
      }
    }
    if (wenkuOutlines != null) {
      for (var wenkuOutline in wenkuOutlines) {
        if (wenkuOutline.favored != null) {
          newFavoredMap[wenkuOutline.id] = wenkuOutline.favored!;
        }
      }
    }
    if (webNovelDtoData != null) {
      if (webNovelDtoData.$2.favored != null) {
        newFavoredMap[webNovelDtoData.$1] = webNovelDtoData.$2.favored!;
      }
    }
    if (wenkuNovelDtoData != null) {
      if (wenkuNovelDtoData.$2.favored != null) {
        newFavoredMap[wenkuNovelDtoData.$1] = wenkuNovelDtoData.$2.favored!;
      }
    }
    if (simpleFavored != null) {
      if (simpleFavored.$2 == null) {
        newFavoredMap.remove(simpleFavored.$1);
      } else {
        newFavoredMap[simpleFavored.$1] = simpleFavored.$2!;
      }
    }
    emit(state.copyWith(
        novelToFavoredIdMap: {...state.novelToFavoredIdMap, ...newFavoredMap}));
  }
}
