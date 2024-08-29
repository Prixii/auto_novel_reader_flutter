import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:image/image.dart';

final epubUtil = _EpubUtil();

class _EpubUtil {
  final basePath = '${localFileManager.externalStorageDirectory}/parse/epub';

  epubx.EpubBook? epubBook;
  String title = '';
  List<String?> authorList = [];
  epubx.Image? coverImage;
  List<epubx.EpubTextContentFile> htmlContent = [];
  List<epubx.EpubNavigationPoint> pointList = [];
  String? currentPath;
  List<epubx.EpubChapter> chapterList = [];
  Map<String, List<String>> chapterResourceMap = {};

  late String uid;

  _EpubUtil();

  Future<EpubManageData?> parseEpub(File epub) async {
    try {
      localFileCubit.updateProgress(message: '读取 epub 文件...');
      final bytes = await epub.readAsBytes();
      epubBook = await epubx.EpubReader.readBook(bytes);
      if (epubBook == null) return null;
      uid = epubBook.hashCode.toString();

      localFileCubit.updateProgress(progress: 33, message: '解析 epub 结构...');
      _parseBaseInfo();
      _parseNcx();

      localFileCubit.updateProgress(progress: 66, message: '提取内容...');
      await _extractContent(uid);
      chapterResourceMap = await _sortChapters();
      await _extractCover(uid);
      await _extractEpubBackup(epub, uid);
      final epubData = EpubManageData(
        path: epub.path,
        name: epubBook!.Title ?? uid,
        uid: uid,
        chapterResourceMap: chapterResourceMap,
      );

      localFileCubit.updateProgress(progress: 100, message: '解析完成');
      return epubData;
    } catch (e) {
      throw Exception(e);
    }
  }

  void _parseBaseInfo() {
    if (epubBook == null) return;
    title = epubBook!.Title ?? '';
    coverImage = epubBook!.CoverImage;
    authorList = epubBook!.AuthorList ?? [];
    chapterList = epubBook!.Chapters ?? [];
  }

  void _parseNcx() {
    final ncx = epubBook?.Schema?.Navigation;
    if (ncx == null) return;

    pointList = ncx.NavMap?.Points ?? [];
  }

  Future<Map<String, List<String>>> _sortChapters() async {
    var htmlNameList = <String>[];
    var currentChapterName = '';
    var chapterMap = <String, List<String>>{};
    var addFirstChapter = false;
    // 处理第一章
    if (htmlContent.isNotEmpty) {
      if (htmlContent[0].FileName != pointList[0].sourceName) {
        chapterList.insert(0, epubx.EpubChapter());
        addFirstChapter = true;
      }
    }
    int htmlIndex = 0;
    for (var i = 0; i < pointList.length; i++) {
      final navPoint = pointList[i];
      final sourceName = navPoint.sourceName;
      while (true) {
        if (htmlIndex >= htmlContent.length) break;
        final htmlName = htmlContent[htmlIndex].FileName;
        if (sourceName == htmlName) {
          if (currentChapterName == '') {
            currentChapterName = 'Chapter${i + 1}';
          }
          if (htmlNameList.isNotEmpty) {
            chapterMap[currentChapterName] = htmlNameList;
            htmlNameList = [htmlName ?? ''];
          }
          currentChapterName =
              chapterList[i + (addFirstChapter ? 1 : 0)].Title ?? '';
          htmlIndex++;
          break;
        } else {
          htmlNameList.add(htmlName ?? '');
        }
        htmlIndex++;
      }
    }
    if (htmlIndex < htmlContent.length) {
      htmlNameList.addAll(htmlContent
          .getRange(htmlIndex, htmlContent.length)
          .map((e) => e.FileName ?? '')
          .toList());
    }
    currentChapterName =
        chapterList.last.Title ?? 'Chapter${chapterList.length + 1}';
    chapterMap[currentChapterName] = htmlNameList;
    htmlNameList = [];
    return chapterMap;
  }

  Future<void> _extractContent(String uid) async {
    final content = epubBook?.Content;
    if (content == null) return;

    htmlContent = content.Html?.values.toList() ?? [];

    final path = getPathByUid(uid);
    currentPath = path;
    final parseDir = Directory(path);
    if (parseDir.existsSync()) return;
    parseDir.createSync(recursive: true);
    await Future.wait([
      extractCss(content, path),
      extractHtml(content, path),
      extractImage(content, path),
    ]);
  }

  Future<void> extractImage(epubx.EpubContent content, String folder) async {
    List<epubx.EpubByteContentFile> images =
        content.Images?.values.toList() ?? [];
    for (final image in images) {
      writeImageToFile(image.Content ?? [], image.FileName ?? '', folder);
    }
  }

  Future<void> extractHtml(epubx.EpubContent content, String folder) async {
    for (final htmlFile in htmlContent) {
      String htmlContent = htmlFile.Content ?? '';
      await writeStringToFile(htmlFile.FileName ?? '', htmlContent, folder);
    }
  }

  Future<void> extractCss(epubx.EpubContent content, String folder) async {
    List<epubx.EpubTextContentFile> cssFiles =
        content.Css?.values.toList() ?? [];
    for (var cssFile in cssFiles) {
      String cssContent = cssFile.Content ?? '';
      await writeStringToFile(cssFile.FileName ?? '', cssContent, folder);
    }
  }

  String getChapterNameByIndex(int index) {
    if (chapterList.length <= index) throw 'chapter index out of range';
    return chapterList[index].Title ?? '';
  }

  List<String> getChapterContentNameByIndex(int index) {
    if (chapterResourceMap.length <= index) throw 'chapter index out of range';
    return chapterResourceMap[pointList[index].hashCode.toString()] ?? [];
  }

  Future<void> _extractCover(String uid) async {
    final path = '$basePath/cover/$uid';
    final file = File(path);
    if (coverImage == null) {
      final imageList = epubBook?.Content?.Images?.values.toList();
      if (imageList == null || imageList.isEmpty) return;
      final firstImageFile = imageList.first;
      file.createSync(recursive: true);
      await file.writeAsBytes(firstImageFile.Content ?? []);
      return;
    } else {
      try {
        file.createSync(recursive: true);
        await file.writeAsBytes(encodePng(coverImage!));
      } catch (e) {
        talker.error('Error writing to file: $e');
      }
    }
  }

  Future<void> _extractEpubBackup(File epub, String uid) async {
    final path = '$basePath/backup/$uid';
    final backup = File(path);
    backup.createSync(recursive: true);
    await backup.writeAsBytes(epub.readAsBytesSync());
    return;
  }

  Future<void> deleteEpubBook(EpubManageData epubData) async {
    final coverFile = '$basePath/cover/${epubData.uid}';
    final cover = File(coverFile);
    if (cover.existsSync()) {
      cover.deleteSync();
    }
    final backupFile = '$basePath/backup/${epubData.uid}';
    final backup = File(backupFile);
    if (backup.existsSync()) {
      backup.deleteSync();
    }
    final path3 = '$basePath/${epubData.uid}';
    final parseDir = Directory(path3);
    if (parseDir.existsSync()) {
      parseDir.deleteSync(recursive: true);
    }
  }

  String getPathByUid(String uid) => '$basePath/$uid';
}

extension EpubNavigationPointExt on epubx.EpubNavigationPoint {
  String? get sourceName {
    return Content?.Source?.split('#').first;
  }
}
