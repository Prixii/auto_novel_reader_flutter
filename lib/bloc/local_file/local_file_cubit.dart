import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'local_file_state.dart';
part 'local_file_cubit.freezed.dart';
part 'local_file_cubit.g.dart';

class LocalFileCubit extends HydratedCubit<LocalFileState> {
  LocalFileCubit() : super(const LocalFileState.initial());

  selectFile({
    required File file,
    required BuildContext context,
  }) async {
    try {
      final epubManageData = await epubUtil.parseEpub(
        file,
        novelType: NovelType.local,
      );

      emit(state.copyWith(
          epubManageDataList: [epubManageData, ...state.epubManageDataList]));
    } catch (e) {
      showErrorToast(e.toString());
      throw Exception(e);
    }
  }

  addEpubManageData(EpubManageData epubManageData) {
    final dataListSnapshot = [epubManageData, ...state.epubManageDataList];
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
  }

  updateEpubManageData(EpubManageData newData) {
    var dataListSnapshot = [...state.epubManageDataList];
    dataListSnapshot.removeWhere((element) => element.uid == newData.uid);
    dataListSnapshot = [newData, ...dataListSnapshot];
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
  }

  cleanEpubManageData() async {
    emit(state.copyWith(epubManageDataList: []));
    await Future.wait([
      localFileManager.cleanParseDir(),
    ]);
    showSucceedToast('清理完成');
  }

  deleteEpubBook(EpubManageData epubManageData) {
    var dataListSnapshot = [...state.epubManageDataList];
    dataListSnapshot
        .removeWhere((element) => element.uid == epubManageData.uid);
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
    epubUtil.deleteEpubBook(epubManageData);
  }

  EpubManageData? getEpubManageData(String epubUid,
      {NovelType type = NovelType.wenku}) {
    return state.epubManageDataList.firstWhere((data) => data.uid == epubUid);
  }

  @override
  LocalFileState? fromJson(Map<String, dynamic> json) {
    return LocalFileState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(LocalFileState state) {
    return state.toJson();
  }
}
