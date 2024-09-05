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
    requestFavoredNovels();
  }

  Future<void> setFavored({
    NovelType? type,
    Favored? favored,
  }) async {
    final novelType = type ?? state.currentType;
    if (type != null) {
      emit(state.copyWith(
          currentType: type, currentFavored: state.favoredMap[type]!.first));
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
  }) async {
    switch (state.currentType) {
      case NovelType.web:
        await _requestWebFavored(state.currentFavored!.id, sortType);
        break;
      case NovelType.wenku:
        await _requestWenkuFavored(state.currentFavored!.id, sortType);
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
    ));
    _loadWebFavored(favoredId, sortType);
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
    ));
    _loadWenkuFavored(favoredId, sortType);
  }

  Future<void> _loadWebFavored(
    String favoredId,
    SearchSortType sortType,
  ) async {
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
          favoredId: newWebNovelList,
        },
        isWebRequestingMap: {
          ...state.isWebRequestingMap,
          favoredId: false,
        },
      ));
    } catch (e, stacktrace) {
      talker.error('error', e, stacktrace);
      emit(state.copyWith(isWebRequestingMap: {
        ...state.isWebRequestingMap,
        favoredId: false,
      }));
    }
  }

  void _loadWenkuFavored(String favoredId, SearchSortType sortType) {
    emit(state.copyWith(isWenkuRequestingMap: {
      ...state.isWenkuRequestingMap,
      favoredId: true,
    }));
    // 发送请求
    apiClient.userFavoredWenkuService
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
        favoredId: newWenkuNovelList,
      }, isWenkuRequestingMap: {
        ...state.isWenkuRequestingMap,
      }));
    }).catchError((e, stacktrace) {
      talker.error('error', e, stacktrace);
      emit(state.copyWith(isWenkuRequestingMap: {
        ...state.isWenkuRequestingMap,
        favoredId: false,
      }));
    });
  }

  void favor({
    required NovelType type,
    required Favored favored,
    WebNovelOutline? webOutline,
    WenkuNovelOutline? wenkuOutline,
  }) async {
    if (type == NovelType.web) {
      if (webOutline == null) throw Exception('webOutline is null');
      emit(state.copyWith(favoredWebNovelsMap: {
        ...state.favoredWebNovelsMap,
        favored.id: [
          ...state.favoredWebNovelsMap[favored.id]!,
          webOutline,
        ],
      }));
    } else if (type == NovelType.wenku) {
      if (wenkuOutline == null) throw Exception('wenkuOutline is null');
      emit(state.copyWith(favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favored.id: [
          ...state.favoredWenkuNovelsMap[favored.id]!,
          wenkuOutline,
        ],
      }));
    }
  }

  void unFavor({
    required NovelType type,
    required Favored favored,
    required String novelId,
  }) async {
    if (type == NovelType.web) {
      final outlineListSnapshot = state.favoredWebNovelsMap[favored.id];
      emit(state.copyWith(favoredWebNovelsMap: {
        ...state.favoredWebNovelsMap,
        favored.id: [
          ...outlineListSnapshot!
              .where((element) => element.novelId != novelId),
        ]
      }));
    } else if (type == NovelType.wenku) {
      final outlineListSnapshot = state.favoredWenkuNovelsMap[favored.id];
      emit(state.copyWith(favoredWenkuNovelsMap: {
        ...state.favoredWenkuNovelsMap,
        favored.id: [
          ...outlineListSnapshot!.where((element) => element.id != novelId),
        ]
      }));
    }
  }
}
