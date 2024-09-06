import 'dart:io';

import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/network/file_downloader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'download_state.dart';
part 'download_cubit.freezed.dart';
part 'download_cubit.g.dart';

class DownloadCubit extends HydratedCubit<DownloadState> {
  DownloadCubit() : super(const DownloadState.initial());

  init() {
    final taskStatusSnapshot = {...state.taskStatus};
    final taskProgressSnapshot = {...state.taskProgress};
    final taskExtraInfoSnapshot = {...state.taskExtraInfo};
    for (var entry in state.taskStatus.entries) {
      if (entry.value != DownloadStatus.succeed &&
          entry.value != DownloadStatus.failed) {
        taskStatusSnapshot[entry.key] = DownloadStatus.failed;
        taskProgressSnapshot.remove(entry.key);
        taskExtraInfoSnapshot.remove(entry.key);
      }
    }
    emit(state.copyWith(
      taskStatus: taskStatusSnapshot,
      taskProgress: taskProgressSnapshot,
      taskExtraInfo: taskExtraInfoSnapshot,
    ));
  }

  removeTask(String filename) {
    emit(state.copyWith(
      taskStatus: {...state.taskStatus}..remove(filename),
      taskProgress: {...state.taskProgress}..remove(filename),
      taskExtraInfo: {...state.taskExtraInfo}..remove(filename),
    ));
  }

  createDownloadTask(String url, String path, String filename) async {
    final downloadType = getDownloadType(filename);
    switch (downloadType) {
      case DownloadStatus.failed:
        showSucceedToast('已重新创建下载任务');
      case DownloadStatus.none:
        showSucceedToast('已创建下载任务');
        emit(state.copyWith(taskProgress: {
          ...state.taskProgress,
          filename: 0.0,
        }, taskStatus: {
          ...state.taskStatus,
          filename: DownloadStatus.redirecting,
        }));
        downloadFile(url: url, path: path, filename: filename, wenku: true);
      default:
        break;
    }
  }

  updateStatus(String filename, DownloadStatus status) {
    emit(state.copyWith(taskStatus: {
      ...state.taskStatus,
      filename: status,
    }));
  }

  finishRedirect(String filename) {
    updateStatus(filename, DownloadStatus.parsing);
  }

  updateProgress(String filename, double progress) {
    emit(state.copyWith(
      taskProgress: {
        ...state.taskProgress,
        filename: progress,
      },
    ));
  }

  downloadFailed(String filename) {
    finishDownload(filename, false);
  }

  finishDownload(String filename, bool succeed, {File? file}) {
    if (succeed) {
      if (file == null) throw Exception('file is null');
      emit(state.copyWith(
          taskProgress: {...state.taskProgress}..remove(filename),
          taskStatus: {
            ...state.taskStatus,
            filename: DownloadStatus.parsing,
          }));
      _parseEpub(file, filename);
    } else {
      emit(state.copyWith(taskStatus: {
        ...state.taskStatus,
        filename: DownloadStatus.failed,
      }, taskExtraInfo: {
        ...state.taskExtraInfo,
        filename: '下载失败',
      }));
    }
  }

  finishParse(String filename) {
    emit(state.copyWith(
      taskStatus: {
        ...state.taskStatus,
        filename: DownloadStatus.succeed,
      },
    ));
    showSucceedToast('$filename 下载成功');
  }

  parseFailed(String filename, Exception e) {
    emit(state.copyWith(taskStatus: {
      ...state.taskStatus,
      filename: DownloadStatus.failed,
    }, taskExtraInfo: {
      ...state.taskExtraInfo,
      filename: e.toString()
    }));
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

  clearAllTasks() {
    emit(const DownloadState.initial());
    showSucceedToast('已清空下载任务记录');
  }

  DownloadStatus getDownloadType(String filename) {
    return state.taskStatus[filename] ?? DownloadStatus.none;
  }

  @override
  DownloadState? fromJson(Map<String, dynamic> json) {
    return DownloadState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DownloadState state) {
    return state.toJson();
  }
}
