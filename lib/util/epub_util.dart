import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:epubx/epubx.dart' as epubx;

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
  List<String> chapterTitleList = [];

  _EpubUtil();

  Future<void> parseEpub(File epub) async {
    final bytes = await epub.readAsBytes();
    epubBook = await epubx.EpubReader.readBook(bytes);

    parseBaseInfo();
    parseNcx();
    await extractContent();
    await sortChapters();
  }

  void parseBaseInfo() {
    if (epubBook == null) return;
    title = epubBook!.Title ?? '';
    authorList = epubBook!.AuthorList ?? [];
    coverImage = epubBook!.CoverImage;
    final chaptersObject = epubBook!.Chapters ?? [];
    chapterTitleList = [];
    for (var chapter in chaptersObject) {
      chapterTitleList.add(chapter.Title ?? '');
    }
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
    talker.info(chapterResourceMap);
  }

  void parseChapterList() {
    final chapters = epubBook?.Chapters;
    if (chapters == null) return;
  }

  Future<void> extractContent() async {
    final content = epubBook?.Content;
    if (content == null) return;

    htmlContent = content.Html?.values.toList() ?? [];

    final path = '$basePath/$title';
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
    if (chapterTitleList.length <= index) throw 'chapter index out of range';
    return chapterTitleList[index];
  }

  List<String> getChapterContentNameByIndex(int index) {
    if (chapterResourceMap.length <= index) throw 'chapter index out of range';
    return chapterResourceMap[pointList[index].hashCode.toString()] ?? [];
  }
}

extension EpubNavigationPointExt on epubx.EpubNavigationPoint {
  String? get sourceName {
    return Content?.Source?.split('#').first;
  }
}
