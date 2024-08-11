import 'dart:io';

import 'package:auto_novel_reader_flutter/util/client_util.dart';

Future<void> createDirectoryIfNotExists(String path) async {
  final directory = Directory(path);
  if (await directory.exists()) {
    return;
  } else {
    await directory.create(recursive: true);
    talker.debug('已创建文件夹: $path');
  }
}
