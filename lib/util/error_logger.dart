import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';

final errorLogger = _ErrorLogger();

class _ErrorLogger {
  _ErrorLogger() {
    logFilePath = '${pathManager.loggerPath}/$now.log';
    createLogFile();
  }

  final logDivider = '----------------------------------------';

  late final String logFilePath;
  final DateTime now = DateTime.now();

  Future<void> logError(Object e, StackTrace? stackTrace,
      {String extra = ''}) async {
    talker.error(e, stackTrace);
    final String logMessage = _formatLogMessage(e, stackTrace, extra);
    await _writeLogToFile(logMessage);
  }

  String _formatLogMessage(Object e, StackTrace? stackTrace, String extra) {
    final DateTime now = DateTime.now();
    return '[$now] ERROR: $e\nstackTrace: $stackTrace\n$extra\n$logDivider\n';
  }

  Future<void> _writeLogToFile(String logMessage) async {
    try {
      await createLogFile();
      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e, stackTrace) {
      talker.error(e, stackTrace);
    }
  }

  Future<void> createLogFile() async {
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }
  }

  File get logFile => File(logFilePath);

  List<String> getLogPathList() => pathManager.getLogPathList();

  Future<void> cleanAllLogs() async {
    final fileNameToKeep = logFilePath;
    try {
      Directory directory = Directory(pathManager.loggerPath);
      if (!await directory.exists()) {
        return;
      }
      List<FileSystemEntity> files = directory.listSync();
      for (FileSystemEntity file in files) {
        if (file is File && file.path.split('/').last != fileNameToKeep) {
          try {
            await file.delete();
            showSucceedToast('已清除日志缓存');
          } catch (e, stackTrace) {
            logError(e, stackTrace);
          }
        }
      }
    } catch (e, stackTrace) {
      logError(e, stackTrace);
    }
  }
}
