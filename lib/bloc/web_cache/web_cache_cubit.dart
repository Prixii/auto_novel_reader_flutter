import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'web_cache_state.dart';
part 'web_cache_cubit.freezed.dart';
part 'web_cache_cubit.g.dart';

class WebCacheCubit extends HydratedCubit<WebCacheState> {
  WebCacheCubit() : super(const WebCacheState.initial());

  Future<void> updateLastReadChapter(
    String providerId,
    String novelId,
    String? chapterId,
  ) async {
    if (chapterId == null) return;
    emit(state.copyWith(
      lastReadChapterMap: {
        ...state.lastReadChapterMap,
        '$providerId$novelId': chapterId
      },
    ));
  }

  Future<void> refreshFavored() async {
    // 没有则设置默认值
    if (!userCubit.isSignIn) {
      emit(state.copyWith(
          localFavored: localFavored,
          webFavored: webFavored,
          wenkuFavored: wenkuFavored));
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
      localFavored: localFavored,
      webFavored: parseToFavored(body['favoredWeb']),
      wenkuFavored: parseToFavored(body['favoredWenku']),
    ));
  }

  @override
  WebCacheState? fromJson(Map<String, dynamic> json) =>
      WebCacheState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(WebCacheState state) => state.toJson();

  List<Favored> parseToFavored(dynamic body) {
    var favoreds = <Favored>[];
    for (var item in body) {
      favoreds.add(Favored(id: item['id'], title: item['title']));
    }
    if (favoreds.isEmpty) favoreds.add(Favored.createDefault());
    return favoreds;
  }

  List<Favored> get localFavored => (state.localFavored.isEmpty)
      ? [Favored.createDefault()]
      : state.localFavored;

  List<Favored> get webFavored =>
      (state.webFavored.isEmpty) ? [Favored.createDefault()] : state.webFavored;

  List<Favored> get wenkuFavored => (state.wenkuFavored.isEmpty)
      ? [Favored.createDefault()]
      : state.wenkuFavored;
}
