import 'dart:io';

import 'package:path_provider/path_provider.dart';

final pathManager = _PathManager();

class _PathManager {
  late String externalStorageDirectory;

  final _epubDownloadPath = '/downloads/epub';
  final _parseDirPath = '/parse/epub';
  final _epubCoverPath = '/parse/epub/cover';
  final _backupPath = '/parse/epub/backup';
  final _loggerPath = '/log';

  _PathManager();

  Future<void> init() async {
    await _getExternalStorageDirectory();
  }

  Future<void> _getExternalStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('no external storage');
    externalStorageDirectory = directory.path;
  }

  String? getEpubFilePath(String filename) {
    return '$epubDownloadPath/$filename';
  }

  String? getCoverFilePath(String filename) {
    return '$epubCoverPath/$filename';
  }

  List<String> getLogPathList() {
    Directory directory = Directory(loggerPath);
    List<FileSystemEntity> files = directory.listSync();

    // 过滤出 .log 文件
    List<FileSystemEntity> logFiles = files.where((file) {
      return file.path.endsWith('.log');
    }).toList();
    return logFiles.map((file) => file.path).toList();
  }

  /// externalStorageDirectory/parse/epub/cover
  String get epubCoverPath => externalStorageDirectory + _epubCoverPath;

  /// externalStorageDirectory/downloads/epub
  String get epubDownloadPath => externalStorageDirectory + _epubDownloadPath;

  /// externalStorageDirectory/parse/epub
  String get parseDirPath => externalStorageDirectory + _parseDirPath;

  /// externalStorageDirectory/parse/epub/backup
  String get backupPath => externalStorageDirectory + _backupPath;

  String get loggerPath => externalStorageDirectory + _loggerPath;

  String getPathByUid(String uid) => '$parseDirPath/$uid';
  String getThumbnailPath(String path) => '$path.thumbnail';
}
