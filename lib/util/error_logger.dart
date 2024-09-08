import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';

final errorLogger = _ErrorLogger();

class _ErrorLogger {
  _ErrorLogger() {
    logFilePath = '${pathManager.loggerPath}/$now.log';
  }

  late final String logFilePath;
  final DateTime now = DateTime.now();

  Future<void> logError(Object e, StackTrace stackTrace) async {
    final String logMessage = _formatLogMessage(e, stackTrace);
    await _writeLogToFile(logMessage);
  }

  String _formatLogMessage(Object e, StackTrace stackTrace) {
    final DateTime now = DateTime.now();
    return '[$now] ERROR: $e\nSTACKTRACE: $stackTrace\n\n';
  }

  Future<void> _writeLogToFile(String logMessage) async {
    final File logFile = File(logFilePath);
    try {
      if (!await logFile.exists()) {
        await logFile.create(recursive: true);
      }
      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e, stackTrace) {
      talker.error(e, stackTrace);
    }
  }
}
