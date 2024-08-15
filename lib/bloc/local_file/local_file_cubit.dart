import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_file_state.dart';
part 'local_file_cubit.freezed.dart';

class LocalFileCubit extends Cubit<LocalFileState> {
  LocalFileCubit() : super(const LocalFileState.initial());

  init() async {
    emit(
      state.copyWith(
        epubManageDataList: localFileManager.epubManageDataList,
      ),
    );
  }

  selectFile({
    required File file,
    required BuildContext context,
  }) async {
    try {
      final epubManageData = await epubUtil.parseEpub(file);
      if (epubManageData == null) return;
      localFileManager.addEpub(epubManageData);

      emit(state.copyWith(
          epubManageDataList: [epubManageData, ...state.epubManageDataList]));
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
            msg: e.toString(),
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.onError);
      }

      throw Exception(e);
    }
  }

  updateEpubManageData(EpubManageData newData) {
    var dataListSnapshot = [...state.epubManageDataList];
    dataListSnapshot.removeWhere((element) => element.uid == newData.uid);
    dataListSnapshot = [newData, ...dataListSnapshot];
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
    localFileManager.updateEpubManageData(dataListSnapshot);
  }

  deleteEpubBook(EpubManageData epubManageData) {
    var dataListSnapshot = [...state.epubManageDataList];
    dataListSnapshot
        .removeWhere((element) => element.uid == epubManageData.uid);
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
    localFileManager.updateEpubManageData(dataListSnapshot);
    epubUtil.deleteEpubBook(epubManageData);
  }

  updateProgress({int? progress, String? message}) {
    emit(state.copyWith(
      message: message ?? '',
      progress: progress ?? 0,
      loading: progress == 100,
    ));
  }
}
