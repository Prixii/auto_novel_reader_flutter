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
    if (downloadType == DownloadType.downloading) {
      showWarnToast('文件正在下载');
      return;
    }
    if (downloadType == DownloadType.downloaded) {
      showWarnToast('文件已存在');
      return;
    }
    emit(state.copyWith(progressMap: {...state.progressMap, url: 0.0}));
    downloadFile(url: url, path: path, fileName: fileName, wenku: true);
    if (downloadType == DownloadType.failed) {
      showSucceedToast('已重新创建下载任务');
    } else {
      showSucceedToast('已创建下载任务');
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
    emit(state.copyWith(
      progressMap: progressMapSnapshot,
      downloadHistory: [
        (fileName, succeed),
        ...state.downloadHistory,
      ],
    ));
  }

  DownloadType getDownloadType(String fileName) {
    DownloadType? result;
    if (state.progressMap[fileName] != null) {
      result = DownloadType.downloading;
    } else {
      var targetIndex = -1;
      for (var i = 0; i < state.downloadHistory.length; i++) {
        final history = state.downloadHistory[i];
        if (history.$1 == fileName) {
          if (history.$2 == true) {
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
