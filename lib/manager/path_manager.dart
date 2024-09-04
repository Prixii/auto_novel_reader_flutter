import 'package:path_provider/path_provider.dart';

final pathManager = _PathManager();

class _PathManager {
  late String externalStorageDirectory;

  final _epubDownloadPath = '/downloads/epub';
  final _parseDirPath = '/parse/epub';
  final _epubCoverPath = '/parse/epub/cover';
  final _backupPath = '/parse/epub/backup';

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

  /// externalStorageDirectory/parse/epub/cover
  String get epubCoverPath => externalStorageDirectory + _epubCoverPath;

  /// externalStorageDirectory/downloads/epub
  String get epubDownloadPath => externalStorageDirectory + _epubDownloadPath;

  /// externalStorageDirectory/parse/epub
  String get parseDirPath => externalStorageDirectory + _parseDirPath;

  /// externalStorageDirectory/parse/epub/backup
  String get backupPath => externalStorageDirectory + _backupPath;

  String getPathByUid(String uid) => '$parseDirPath/$uid';
}
