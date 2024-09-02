import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_home_event.dart';
part 'web_home_state.dart';
part 'web_home_bloc.freezed.dart';

class WebHomeBloc extends Bloc<WebHomeEvent, WebHomeState> {
  WebHomeBloc() : super(const _Initial()) {
    on<WebHomeEvent>((event, emit) async {
      await event.map(
        init: (_Init value) async => await _onInit(event, emit),
        refreshFavoredWeb: (_RefreshFavoredWeb value) async =>
            await _onRefreshFavoredWeb(event, emit),
      );
    });
  }

  _onInit(WebHomeEvent event, Emitter<WebHomeState> emit) async {
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

  List<WebNovelOutline> parseToWebNovelOutline(dynamic body) {
    try {
      final items = body['items'] as List<dynamic>;
      var webNovelOutlines = <WebNovelOutline>[];
      for (final item in items) {
        webNovelOutlines.add(
          WebNovelOutline(
            item['titleJp'],
            item['providerId'],
            item['novelId'],
            titleZh: item['titleZh'],
            type: item['type'],
            attentions: item['attentions'].cast<String>(),
            keywords: item['keywords'].cast<String>(),
            total: item['total'],
            jp: item['jp'],
            baidu: item['baidu'],
            youdao: item['youdao'],
            gpt: item['gpt'],
            sakura: item['sakura'],
            updateAt: item['updateAt'],
          ),
        );
      }
      return webNovelOutlines;
    } catch (e) {
      return [];
    }
  }

  List<WenkuNovelOutline> parseToWenkuNovelOutline(dynamic body) {
    try {
      final items = body['items'] as List<dynamic>;
      var wenkuNovelOutlines = <WenkuNovelOutline>[];
      for (final item in items) {
        wenkuNovelOutlines.add(
          WenkuNovelOutline(
            item['id'],
            item['title'],
            item['titleZh'],
            item['cover'],
            favored: item['favored'],
          ),
        );
      }
      return wenkuNovelOutlines;
    } catch (e) {
      return [];
    }
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
      final body = response?.body;
      final webNovelOutlines = parseToWebNovelOutline(body);
      return webNovelOutlines;
    });
  }

  _onRefreshFavoredWeb(WebHomeEvent event, Emitter<WebHomeState> emit) async {
    final webNovelOutlines = await refreshFavoredWeb();
    emit(state.copyWith(favoredWeb: webNovelOutlines));
  }
}
