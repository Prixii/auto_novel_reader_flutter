import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_home_event.dart';
part 'web_home_state.dart';
part 'web_home_bloc.freezed.dart';

class WebHomeBloc extends Bloc<WebHomeEvent, WebHomeState> {
  WebHomeBloc() : super(const _Initial()) {
    on<WebHomeEvent>((event, emit) async {
      await event.map(
        init: (event) async => await _onInit(event, emit),
        refreshFavoredWeb: (event) async =>
            await _onRefreshFavoredWeb(event, emit),
        toNovelDetail: (event) async => await _onToNovelDetail(event, emit),
      );
    });
  }

  _onInit(_Init event, Emitter<WebHomeState> emit) async {
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

  _onRefreshFavoredWeb(
      _RefreshFavoredWeb event, Emitter<WebHomeState> emit) async {
    final webNovelOutlines = await refreshFavoredWeb();
    emit(state.copyWith(favoredWeb: webNovelOutlines));
  }

  _onToNovelDetail(_ToNovelDetail event, Emitter<WebHomeState> emit) async {
    if (state.webNovelDtoMap['${event.providerId}${event.novelId}'] != null) {
      emit(state.copyWith(
        currentNovelId: event.novelId,
        currentNovelProviderId: event.providerId,
      ));
      return;
    }

    emit(state.copyWith(
      loadingNovelDetail: true,
      currentNovelId: event.novelId,
      currentNovelProviderId: event.providerId,
    ));
    final response = await apiClient.webNovelService
        .getNovelId(event.providerId, event.novelId);
    final body = response.body;
    try {
      final key = event.providerId + event.novelId;

      final webNovelDto = WebNovelDto(
        body['titleJp'],
        attentions: body['attentions'].cast<String>(),
        authors: parseToAuthorList(body['authors']),
        baidu: body['baidu'],
        favored: body['favored'],
        glossary: Map<String, String>.from(body['glossary']),
        gpt: body['gpt'],
        introductionJp: body['introductionJp'],
        introductionZh: body['introductionZh'],
        jp: body['jp'],
        keywords: body['keywords'].cast<String>(),
        points: body['points'],
        sakura: body['sakura'],
        syncAt: body['syncAt'],
        titleZh: body['titleZh'],
        toc: parseTocList(body['toc']),
        totalCharacters: body['totalCharacters'],
        type: body['type'],
        visited: body['visited'],
        youdao: body['youdao'],
      );

      emit(state.copyWith(
        webNovelDtoMap: {...state.webNovelDtoMap, key: webNovelDto},
      ));
    } catch (e) {
      talker.error(e);
    }
  }
}
