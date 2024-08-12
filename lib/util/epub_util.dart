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
  Map<String, List<String>> chapterResourceMap = {};
  List<epubx.EpubChapter> chapterList = [];
  late String uid;

  _EpubUtil();

  Future<EpubManageData?> parseEpub(File epub) async {
    final bytes = await epub.readAsBytes();
    epubBook = await epubx.EpubReader.readBook(bytes);
    if (epubBook == null) return null;

    uid = epubBook.hashCode.toString();
    final epubData = EpubManageData(
      path: epub.path,
      name: epubBook!.Title ?? uid,
      uid: uid,
    );

    parseBaseInfo();
    parseNcx();
    await extractContent(epubData.uid);
    await sortChapters();
    await extractCover(uid);
    await extractEpubBackup(epub, epubData);
    return epubData;
  }

  void parseBaseInfo() {
    if (epubBook == null) return;
    title = epubBook!.Title ?? '';
    authorList = epubBook!.AuthorList ?? [];
    coverImage = epubBook!.CoverImage;
    chapterList = epubBook!.Chapters ?? [];
  }

  void parseNcx() {
    final ncx = epubBook?.Schema?.Navigation;
    if (ncx == null) return;

    pointList = ncx.NavMap?.Points ?? [];
  }

  Future<void> sortChapters() async {
    var index = 0;
    var htmlNameList = <String>[];
    var currentChapterName = '';
    for (final navPoint in pointList) {
      while (true) {
        if (index >= htmlContent.length) {
          currentChapterName = navPoint.hashCode.toString();
          chapterResourceMap[currentChapterName] = htmlNameList;
          htmlNameList = [];
          break;
        }
        final htmlName = htmlContent[index].FileName;
        if (navPoint.sourceName == htmlName) {
          currentChapterName = navPoint.hashCode.toString();
          chapterResourceMap[currentChapterName] = htmlNameList;
          htmlNameList = [];
          break;
        } else {
          htmlNameList.add(htmlName ?? '');
          index++;
        }
      }
    }
  }

  void parseChapterList() {
    final chapters = epubBook?.Chapters;
    if (chapters == null) return;
  }

  Future<void> extractContent(String uid) async {
    final content = epubBook?.Content;
    if (content == null) return;

    htmlContent = content.Html?.values.toList() ?? [];

    final path = '$basePath/$uid';
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

  Future<void> extractCover(String uid) async {
    if (coverImage == null) return;
    final path = '$basePath/cover/$uid';
    try {
      final file = File(path);
      file.createSync(recursive: true);
      await file.writeAsBytes(encodePng(coverImage!));
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  Future<void> extractEpubBackup(File epub, EpubManageData epubData) async {
    final path = '$basePath/backup/${epubData.uid}';
    final backup = File(path);
    backup.createSync(recursive: true);
    await backup.writeAsBytes(epub.readAsBytesSync());
    return;
  }
}

extension EpubNavigationPointExt on epubx.EpubNavigationPoint {
  String? get sourceName {
    return Content?.Source?.split('#').first;
  }
}
