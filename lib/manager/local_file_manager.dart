import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localFileManager = _LocalFileManager();

// IDEA 通过 PathManager 统一存储路径获取方式

class _LocalFileManager {
  late Box epubManagerBox;

  var epubManageDataList = <EpubManageData>[];
  var epubNameList = <String>[];

  _LocalFileManager();

  Future<void> init() async {
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
    final coverPath = pathManager.getCoverFilePath(epubUid);
    if (coverPath == null) return null;
    final coverFile = File(coverPath);
    return coverFile.existsSync() ? coverFile : null;
  }

  Future<void> initEpubDownloadDir() async {
    final path = pathManager.epubDownloadPath;
    createDirectoryIfNotExists(path);
  }

  Future<void> updateEpubManageData(List<EpubManageData> newDataList) async {
    await epubManagerBox.put('epubManageDataList', newDataList);
  }

  Future<void> cleanParseDir() async {
    final path = pathManager.parseDirPath;
    await deleteDirectory(path);
  }
}
