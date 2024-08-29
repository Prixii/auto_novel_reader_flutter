import 'dart:io';

import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final localFileManager = _LocalFileManager();

// IDEA 通过 PathManager 统一存储路径获取方式

class _LocalFileManager {
  late String externalStorageDirectory;
  late Box epubManagerBox;

  var epubManageDataList = <EpubManageData>[];
  var epubNameList = <String>[];

  final parseDirPath = '/parse/epub';
  final epubDownloadPath = '/downloads/epub';
  final epubCoverPath = '/parse/epub/cover';
  final backupPath = '/parse/epub/backup';

  _LocalFileManager();

  Future<void> init() async {
    await getDirectory();
    await Future.wait([
      initEpubDownloadDir(),
      // TODO 替换成 hydrated_bloc 实现
      Hive.initFlutter().then((_) async {
        Hive.registerAdapter<EpubManageData>(EpubManageDataImplAdapter());
        epubManagerBox = await Hive.openBox('epubBox');
        readLocalFileData();
      }),
    ]);
  }

  void readLocalFileData() {
    epubManageDataList = [];
    final dataList = epubManagerBox.get('epubManageDataList') ?? [];
    for (final data in dataList) {
      if (data is EpubManageData) {
        epubManageDataList.add(data);
      }
    }
    localFileCubit.init();
  }

  void addEpub(EpubManageData newData) {
    epubManagerBox.put('epubManageDataList', [newData, ...epubManageDataList]);
  }

  Future<File?> getCover(String epubUid) async {
    final basePath = '$externalStorageDirectory$epubCoverPath';
    createDirectoryIfNotExists(basePath);
    final coverFile = File('$basePath/$epubUid');
    return coverFile.existsSync() ? coverFile : null;
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
    return '$externalStorageDirectory$backupPath/$fileName';
  }

  Future<void> updateEpubManageData(List<EpubManageData> newDataList) async {
    await epubManagerBox.put('epubManageDataList', newDataList);
  }

  Future<void> cleanParseDir() async {
    final path = '$externalStorageDirectory$parseDirPath';
    await deleteDirectory(path);
  }
}
