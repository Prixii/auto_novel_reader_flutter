import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_state.dart';
part 'history_cubit.freezed.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState.initial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    if (state.isRequesting) return;
    emit(state.copyWith(currentPage: 0, histories: []));
    _requestHistory();
  }

  Future<void> loadNextPage() async {
    if (state.isRequesting) return;
    if (state.currentPage + 1 >= state.maxPage) return;
    emit(state.copyWith(currentPage: state.currentPage + 1));
    await _requestHistory();
  }

  Future<void> _requestHistory() async {
    try {
      if (state.isRequesting) return;
      emit(state.copyWith(isRequesting: true));
      final response = await apiClient.userReadHistoryWebService.getList(
        page: state.currentPage,
      );
      if (response == null) {
        emit(state.copyWith(isRequesting: true));
        return;
      }
      if (response.statusCode == 502) {
        emit(state.copyWith(isRequesting: false));
        showErrorToast('服务器繁忙, 请稍后再试');
        return;
      }
      if (response.statusCode != 200) {
        emit(state.copyWith(isRequesting: false));
        showErrorToast('获取失败, 请稍后再试');
        return;
      }
      final body = response.body;
      final maxPage = body['pageNumber'];
      final newDtoList = parseToWebNovelOutline(body);
      emit(state.copyWith(
        histories: [...state.histories, ...newDtoList],
        maxPage: maxPage,
        isRequesting: false,
      ));
    } catch (e, stacktrace) {
      emit(state.copyWith(
        isRequesting: false,
      ));
      talker.error('', e, stacktrace);
    }
  }
}
