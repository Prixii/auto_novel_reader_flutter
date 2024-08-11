import 'dart:io';

import 'package:auto_novel_reader_flutter/util/client_util.dart';

Future<void> createDirectoryIfNotExists(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
    talker.debug('已创建文件夹: $path');
  }
}

Future<void> writeStringToFile(String name, String content, String path) async {
  try {
    final file = File('$path/$name');
    if (!file.parent.existsSync()) file.parent.createSync();
    await file.writeAsString(content);
  } catch (e) {
    talker.error('Error writing file: $e');
  }
}

Future<void> writeImageToFile(
    List<int> imageData, String name, String path) async {
  try {
    final file = File('$path/$name');
    if (!file.parent.existsSync()) file.parent.createSync();
    await file.writeAsBytes(imageData);
  } catch (e) {
    talker.error('Error writing image: $e');
  }
}
