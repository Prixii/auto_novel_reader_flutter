import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/network/file_downloader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_state.dart';
part 'download_cubit.freezed.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(const DownloadState.initial());

  createDownloadTask(String url, String path, String filename) async {
    final downloadType = getDownloadType(filename);
    switch (downloadType) {
      case DownloadType.downloading:
        showWarnToast('文件正在下载');
        break;
      case DownloadType.downloaded:
        showWarnToast('文件已存在');
        break;
      case DownloadType.parsing:
        showWarnToast('文件正在解析');
        break;
      case DownloadType.failed:
        showSucceedToast('已重新创建下载任务');
      case DownloadType.none:
        showSucceedToast('已创建下载任务');
        emit(state.copyWith(progressMap: {
          ...state.progressMap,
          filename: 0.0,
        }));
        downloadFile(url: url, path: path, filename: filename, wenku: true);
    }
  }

  updateProgress(String filename, double progress) {
    emit(state.copyWith(
      progressMap: {
        ...state.progressMap,
        filename: progress,
      },
    ));
  }

  downloadFailed(String filename) {
    finishDownload(filename, false);
  }

  finishDownload(String filename, bool succeed, {File? file}) {
    var progressMapSnapshot = {...state.progressMap};
    progressMapSnapshot.remove(filename);
    if (succeed) {
      if (file == null) throw Exception('file is null');
      var parseMapSnapshot = {...state.parseMap};
      emit(state.copyWith(
        parseMap: parseMapSnapshot,
        progressMap: progressMapSnapshot,
      ));
      _parseEpub(file, filename);
    } else {
      emit(state.copyWith(
        progressMap: progressMapSnapshot,
        downloadHistory: [
          (filename, ''),
          ...state.downloadHistory,
        ],
      ));
    }
  }

  finishParse(String filename) {
    var parseMapSnapshot = {...state.parseMap};
    parseMapSnapshot.remove(filename);
    emit(state.copyWith(
      parseMap: parseMapSnapshot,
      downloadHistory: [
        (filename, ''),
        ...state.downloadHistory,
      ],
    ));
  }

  parseFailed(String filename, Exception e) {
    var parseMapSnapshot = {...state.parseMap, filename};
    emit(state.copyWith(
      parseMap: parseMapSnapshot,
      downloadHistory: [
        (filename, e.toString()),
        ...state.downloadHistory,
      ],
    ));
  }

  Future<void> _parseEpub(File epub, String filename) async {
    try {
      final epubManageData = await epubUtil.parseEpub(
        epub,
        novelType: NovelType.wenku,
        filename: filename,
      );
      localFileCubit.addEpubManageData(epubManageData);
      finishParse(filename);
    } catch (e) {
      parseFailed(filename, Exception(e));
    }
  }

  DownloadType getDownloadType(String filename) {
    DownloadType? result;
    if (state.progressMap[filename] != null) {
      result = DownloadType.downloading;
    } else if (state.parseMap.contains(filename)) {
      result = DownloadType.parsing;
    } else {
      var targetIndex = -1;
      for (var i = 0; i < state.downloadHistory.length; i++) {
        final history = state.downloadHistory[i];
        if (history.$1 == filename) {
          if (history.$2 == '') {
            final file = File('${pathManager.epubDownloadPath}/$filename');
            if (file.existsSync()) {
              result = DownloadType.downloaded;
              break;
            }
          }
          result = DownloadType.failed;
          break;
        }
      }
      if (targetIndex != -1) {
        state.downloadHistory.removeAt(targetIndex);
      }
    }

    result ??= DownloadType.none;

    return result;
  }
}
