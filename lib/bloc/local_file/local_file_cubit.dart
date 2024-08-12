import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
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
    final epubManageData = await epubUtil.parseEpub(file);
    if (epubManageData == null) return;
    localFileManager.addEpub(epubManageData);

    emit(state.copyWith(
        epubManageDataList: [epubManageData, ...state.epubManageDataList]));
    if (context.mounted) {
      readEpubViewerBloc(context)
          .add(EpubViewerEvent.open(file, epubManageData, context));
    }
  }

  updateEpubManageData(EpubManageData newData) {
    var dataListSnapshot = [...state.epubManageDataList];
    dataListSnapshot.removeWhere((element) => element.uid == newData.uid);
    dataListSnapshot = [newData, ...dataListSnapshot];
    emit(state.copyWith(epubManageDataList: dataListSnapshot));
    localFileManager.updateEpubManageData(dataListSnapshot);
  }
}
