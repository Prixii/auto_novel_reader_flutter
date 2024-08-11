import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:path_provider/path_provider.dart';

final localFileManager = LocalFileManager();

class LocalFileManager {
  late String externalStorageDirectory;
  final epubDownloadPath = '/downloads/epub';

  LocalFileManager();

  Future<void> init() async {
    await getDirectory();
    await Future.wait([initEpubDownloadDir()]);
  }

  Future<void> getDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('no external storage');
    externalStorageDirectory = directory.path;
  }

  Future<void> initEpubDownloadDir() async {
    final path = '$externalStorageDirectory$epubDownloadPath';
    createDirectoryIfNotExists(path);
  }

  String? getEpubFilePath(String fileName) {
    return '$externalStorageDirectory$epubDownloadPath/$fileName.epub';
  }
}
