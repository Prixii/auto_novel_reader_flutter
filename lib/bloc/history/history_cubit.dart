import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_state.dart';
part 'history_cubit.freezed.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState.initial());

  setLoadingStatus(Map<RequestLabel, LoadingStatus?> newStatusMap) {
    emit(state.copyWith(loadingStatusMap: {
      ...state.loadingStatusMap,
      ...newStatusMap,
    }));
  }

  setHistoryOutlines(List<WebNovelOutline> newHistories) {
    emit(state.copyWith(histories: newHistories));
  }
}
