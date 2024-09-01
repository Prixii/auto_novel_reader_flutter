import 'package:path_provider/path_provider.dart';

final pathManager = _PathManager();

class _PathManager {
  late String externalStorageDirectory;

  final _epubDownloadPath = '/downloads/epub';
  final _parseDirPath = '/parse/epub';
  final _epubCoverPath = '/parse/epub/cover';
  final _backupPath = '/parse/epub/backup';

  _PathManager() {
    _getExternalStorageDirectory();
  }

  Future<void> _getExternalStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('no external storage');
    externalStorageDirectory = directory.path;
  }

  String? getEpubFilePath(String fileName) {
    return '$epubDownloadPath$fileName';
  }

  String? getCoverFilePath(String fileName) {
    return '$epubCoverPath$fileName';
  }

  String get epubCoverPath => externalStorageDirectory + _epubCoverPath;
  String get epubDownloadPath => externalStorageDirectory + _epubDownloadPath;
  String get parseDirPath => externalStorageDirectory + _parseDirPath;
  String get backupPath => externalStorageDirectory + _backupPath;
}
