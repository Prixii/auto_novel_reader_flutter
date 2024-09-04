import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/network/file_downloader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_state.dart';
part 'download_cubit.freezed.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(const DownloadState.initial());

  createDownloadTask(String url, String path, String fileName) async {
    final downloadType = getDownloadType(fileName);
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
          fileName: 0.0,
        }));
        downloadFile(url: url, path: path, fileName: fileName, wenku: true);
    }
  }

  updateProgress(String fileName, double progress) {
    if (progress == 1) {
      _finishDownload(fileName, true);
    } else {
      emit(state.copyWith(
        progressMap: {
          ...state.progressMap,
          fileName: progress,
        },
      ));
    }
  }

  downloadFailed(String fileName) {
    _finishDownload(fileName, false);
  }

  _finishDownload(String fileName, bool succeed) {
    var progressMapSnapshot = {...state.progressMap};
    progressMapSnapshot.remove(fileName);

    if (succeed) {
      var parseMapSnapshot = {...state.parseMap};
      emit(state.copyWith(
        parseMap: parseMapSnapshot,
        progressMap: progressMapSnapshot,
      ));
    } else {
      emit(state.copyWith(
        progressMap: progressMapSnapshot,
        downloadHistory: [
          (fileName, ''),
          ...state.downloadHistory,
        ],
      ));
    }
  }

  finishParse(String fileName) {
    var parseMapSnapshot = {...state.parseMap};
    parseMapSnapshot.remove(fileName);
    emit(state.copyWith(
      parseMap: parseMapSnapshot,
      downloadHistory: [
        (fileName, ''),
        ...state.downloadHistory,
      ],
    ));
  }

  parseFailed(String fileName, Exception e) {
    var parseMapSnapshot = {...state.parseMap, fileName};
    emit(state.copyWith(
      parseMap: parseMapSnapshot,
      downloadHistory: [
        (fileName, e.toString()),
        ...state.downloadHistory,
      ],
    ));
  }

  DownloadType getDownloadType(String fileName) {
    DownloadType? result;
    if (state.progressMap[fileName] != null) {
      result = DownloadType.downloading;
    } else if (state.parseMap.contains(fileName)) {
      result = DownloadType.parsing;
    } else {
      var targetIndex = -1;
      for (var i = 0; i < state.downloadHistory.length; i++) {
        final history = state.downloadHistory[i];
        if (history.$1 == fileName) {
          if (history.$2 == '') {
            result = DownloadType.downloaded;
            // TODO 校验文件存在性
            break;
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
