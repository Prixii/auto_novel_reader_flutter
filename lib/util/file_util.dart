import 'dart:io';

import 'package:auto_novel_reader_flutter/util/error_logger.dart';

Future<void> createDirectoryIfNotExists(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
}

Future<void> writeStringToFile(String name, String content, String path) async {
  try {
    final file = File('$path/$name');
    if (!file.parent.existsSync()) file.parent.createSync();
    await file.writeAsString(content);
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
  }
}

Future<void> writeImageToFile(
    List<int> imageData, String name, String path) async {
  try {
    final file = File('$path/$name');
    if (!file.parent.existsSync()) file.parent.createSync();
    await file.writeAsBytes(imageData);
  } catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
  }
}

Future<void> deleteDirectory(String path) async {
  final directory = Directory(path);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
