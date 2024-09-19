import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:chopper/chopper.dart';
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
    final body = response?.body;
    final webFavoredList = parseToFavored(body['favoredWeb']);
    final wenkuFavoredList = parseToFavored(body['favoredWenku']);
    emit(state.copyWith(
      favoredMap: {
        NovelType.local: localFavored,
        NovelType.web: webFavoredList,
        NovelType.wenku: wenkuFavoredList,
      },
      currentFavored: webFavoredList.isEmpty
          ? Favored.createDefault()
          : webFavoredList.first,
      currentType: NovelType.web,
    ));
  }

  List<Favored> parseToFavored(dynamic body) {
    var favoreds = <Favored>[];
    for (var item in body) {
      favoreds.add(Favored(id: item['id'], title: item['title']));
    }
    if (favoreds.isEmpty) favoreds.add(Favored.createDefault());
    return favoreds;
  }

  Future<void> setFavored({
    NovelType? type,
    Favored? favored,
    SearchSortType? sortType,
  }) async {
    if (!userCubit.isSignIn) return;
    final novelType = type ?? state.currentType;
    if (type != null) {
      emit(state.copyWith(
        currentType: type,
        currentFavored:
            state.favoredMap[novelType]?.first ?? Favored.createDefault(),
        searchSortType: sortType ?? state.searchSortType,
      ));
    }
    if (favored != null) {
      emit(state.copyWith(
        currentType: novelType,
        currentFavored: favored,
      ));
    }
    if (sortType != null) {
      emit(state.copyWith(searchSortType: sortType));
    }
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

  // 用来设置小说是否收藏
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

  Future<bool> createFavored({
    required String favoredName,
    required NovelType type,
  }) async {
    late Response<dynamic>? response;
    if (NovelType.web == type) {
      response = await apiClient.userFavoredWebService.postWeb(
        {'title': favoredName},
      );
    } else if (NovelType.wenku == type) {
      response = await apiClient.userFavoredWenkuService.postWenku(
        {'title': favoredName},
      );
    } else {
      showErrorToast('不支持的类型');
      throw Exception('不支持的类型');
    }

    if (response != null && response.isSuccessful) {
      emit(state.copyWith(favoredMap: {
        ...state.favoredMap,
        type: [
          ...state.favoredMap[type]!,
          Favored(id: response.body, title: favoredName),
        ]
      }));
      showSucceedToast('创建收藏夹成功');
      return true;
    } else {
      showErrorToast('创建收藏夹失败, ${response?.statusCode}');

      return false;
    }
  }

  Future<bool> renameFavored({
    required String favoredName,
    required String favoredId,
    required NovelType type,
  }) async {
    late Response<dynamic>? response;
    if (NovelType.web == type) {
      response = await apiClient.userFavoredWebService.putId(
        favoredId,
        {'title': favoredName},
      );
    } else if (NovelType.wenku == type) {
      response = await apiClient.userFavoredWenkuService.putId(
        favoredId,
        {'title': favoredName},
      );
    } else {
      showErrorToast('不支持的类型');
      throw Exception('不支持的类型');
    }

    if (response != null && response.isSuccessful) {
      final newFavored = Favored(id: favoredId, title: favoredName);
      emit(
        state.copyWith(
          favoredMap: {
            ...state.favoredMap,
            type: [
              ...state.favoredMap[type]!
                  .where((element) => element.id != favoredId),
              newFavored,
            ]
          },
          currentFavored: isCurrentFavored(favoredId) ? newFavored : null,
        ),
      );
      showSucceedToast('重命名收藏夹成功');
      return true;
    } else {
      showErrorToast('重命名收藏夹失败, ${response?.statusCode}');

      return false;
    }
  }

  Future<bool> deleteFavored({
    required String favoredId,
    required NovelType type,
  }) async {
    late Response<dynamic>? response;
    if (NovelType.web == type) {
      response = await apiClient.userFavoredWebService.delId(favoredId);
    } else if (NovelType.wenku == type) {
      response = await apiClient.userFavoredWenkuService.delId(favoredId);
    } else {
      showErrorToast('不支持的类型');
      throw Exception('不支持的类型');
    }

    if (response != null && response.isSuccessful) {
      Favored? newCurrent;
      if (isCurrentFavored(favoredId)) {
        switch (state.currentType) {
          case NovelType.web:
            newCurrent = state.favoredMap[NovelType.web]!.first;
            break;
          case NovelType.wenku:
            newCurrent = state.favoredMap[NovelType.wenku]!.first;
            break;
          case NovelType.local:
            throw Exception('不支持的类型');
        }
      }
      emit(
        state.copyWith(
          favoredMap: {
            ...state.favoredMap,
            type: state.favoredMap[type]!
                .where((element) => element.id != favoredId)
                .toList(),
          },
          currentFavored: newCurrent,
        ),
      );
      showSucceedToast('删除收藏夹成功');
      return true;
    } else {
      showErrorToast('删除收藏夹失败, ${response?.statusCode}');

      return false;
    }
  }

  setFavoredNovelList(
    NovelType type,
    String favoredId, {
    List<WebNovelOutline>? webNovels,
    List<WenkuNovelOutline>? wenkuNovels,
  }) {
    assert(type == NovelType.web || type == NovelType.wenku);
    assert(type != NovelType.web || webNovels != null);
    assert(type != NovelType.wenku || wenkuNovels != null);
    switch (type) {
      case NovelType.web:
        emit(state.copyWith(favoredWebNovelsMap: {
          ...state.favoredWebNovelsMap,
          favoredId: webNovels!,
        }));
        break;
      case NovelType.wenku:
        emit(state.copyWith(favoredWenkuNovelsMap: {
          ...state.favoredWenkuNovelsMap,
          favoredId: wenkuNovels!,
        }));
        break;
      default:
    }
  }

  setLoadingStatus(Map<String, LoadingStatus?> newStatusMap) {
    emit(state.copyWith(loadingStatusMap: {
      ...state.loadingStatusMap,
      ...newStatusMap,
    }));
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

  bool isCurrentFavored(String favoredId) =>
      (state.currentFavored?.id == favoredId);
}
