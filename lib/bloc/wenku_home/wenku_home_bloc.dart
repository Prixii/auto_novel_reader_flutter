import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
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
      );
    });
  }

  _onInit(_Init event, Emitter<WenkuHomeState> emit) async {
    await loadPagedWenkuOutline(level: 1).then(
      (wenkuNovelOutlines) => emit(
        state.copyWith(wenkuLatestUpdate: wenkuNovelOutlines),
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
}
