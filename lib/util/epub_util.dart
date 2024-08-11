import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:epubx/epubx.dart' as epubx;

final epubUtil = _EpubUtil();

class _EpubUtil {
  final basePath = '${localFileManager.externalStorageDirectory}/parse/epub';

  epubx.EpubBook? epubBook;
  String title = '';
  List<String?> authorList = [];
  epubx.Image? coverImage;
  List<epubx.EpubNavigationPoint> pointList = [];
  String? currentPath;
  Map<String, List<String>> chapterResourceMap = {};

  _EpubUtil();

  Future<void> parseEpub(File epub) async {
    final bytes = await epub.readAsBytes();
    epubBook = await epubx.EpubReader.readBook(bytes);

    parseBaseInfo();
    parseNcx();
    await extractContent();
  }

  void parseBaseInfo() {
    if (epubBook == null) return;
    title = epubBook!.Title ?? '';
    authorList = epubBook!.AuthorList ?? [];
    coverImage = epubBook!.CoverImage;
  }

  void parseNcx() {
    final ncx = epubBook?.Schema?.Navigation;
    if (ncx == null) return;

    pointList = ncx.NavMap?.Points ?? [];
  }

  void parseChapterList() {
    final chapters = epubBook?.Chapters;
    if (chapters == null) return;
  }

  void sortChapters() {
    /// TODO 整理章节目录
    /// [完成章节 -> 资源]的映射
  }

  Future<void> extractContent() async {
    final content = epubBook?.Content;
    if (content == null) return;
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
    List<epubx.EpubTextContentFile> htmlFiles =
        content.Html?.values.toList() ?? [];
    for (final htmlFile in htmlFiles) {
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
}

extension EpubNavigationPointExt on epubx.EpubNavigationPoint {
  String? get sourceName {
    return Content?.Source?.split('#').first;
  }
}
