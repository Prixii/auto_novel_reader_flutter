import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:auto_novel_reader_flutter/util/file_util.dart';
import 'package:epubx/epubx.dart' as epubx;
import 'package:image/image.dart';

final epubUtil = _EpubUtil();

class _EpubUtil {
  _EpubUtil();

  Future<EpubManageData> parseEpub(
    File epub, {
    required NovelType novelType,
    String? filename,
  }) async {
    // String title = '';
    // List<String?> authorList = [];
    epubx.EpubBook? epubBook;
    epubx.Image? coverImage;
    List<epubx.EpubTextContentFile> htmlContent = [];
    List<epubx.EpubNavigationPoint> pointList = [];
    List<epubx.EpubChapter> chapterList = [];
    Map<String, List<String>> chapterResourceMap = {};

    late String uid;
    try {
      updateProgress(novelType, message: '读取 epub 文件...');
      final bytes = await epub.readAsBytes();
      epubBook = await epubx.EpubReader.readBook(bytes);
      uid = filename ?? epubBook.hashCode.toString();
      updateProgress(novelType, progress: 10, message: '解析 epub 结构...');

      // --------- parse baseInfo ---------
      // title = epubBook.Title ?? '';
      // authorList = epubBook.AuthorList ?? [];
      coverImage = epubBook.CoverImage;
      chapterList = epubBook.Chapters ?? [];
      // --------- parse ncx ---------
      final ncx = epubBook.Schema?.Navigation;
      if (ncx == null) throw Exception('no ncx');
      pointList = ncx.NavMap?.Points ?? [];
      // --------- extract content ---------
      updateProgress(novelType, progress: 20, message: '提取内容...');
      final content = epubBook.Content;
      htmlContent = content?.Html?.values.toList() ?? [];
      await _extractContent(uid, htmlContent, epubBook);
      updateProgress(novelType, progress: 50, message: '章节划分...');
      chapterResourceMap = await _sortChapters(
        htmlContent,
        pointList,
        chapterList,
      );
      updateProgress(novelType, progress: 70, message: '提取封面...');
      await _extractCover(
        uid,
        coverImage,
        epubBook.Content?.Images?.values.toList(),
      );
      // 如果是本地书籍则备份
      if (novelType == NovelType.local) {
        updateProgress(novelType, progress: 80, message: '备份源文件...');
        await _extractEpubBackup(epub, uid);
      }
      final epubData = EpubManageData(
        path: epub.path,
        name: epubBook.Title ?? uid,
        uid: uid,
        chapterResourceMap: chapterResourceMap,
        novelType: novelType,
        filename: filename,
      );

      updateProgress(novelType, progress: 100, message: '解析完成');
      await Future.delayed(const Duration(milliseconds: 200), () {
        globalBloc.add(const GlobalEvent.endProgress(ProgressType.parsingEpub));
      });
      return epubData;
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      throw Exception(e);
    }
  }

  Future<Map<String, List<String>>> _sortChapters(
      List<epubx.EpubTextContentFile> htmlContent,
      List<epubx.EpubNavigationPoint> pointList,
      List<epubx.EpubChapter> chapterList) async {
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

  Future<void> _extractContent(
    String uid,
    List<epubx.EpubTextContentFile> htmlContent,
    epubx.EpubBook epubBook,
  ) async {
    final content = epubBook.Content;
    if (content == null) return;

    final path = pathManager.getPathByUid(uid);
    final parseDir = Directory(path);
    if (parseDir.existsSync()) [];
    parseDir.createSync(recursive: true);
    await Future.wait([
      extractCss(content, path),
      extractHtml(content, path, htmlContent),
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

  Future<void> extractHtml(
    epubx.EpubContent content,
    String folder,
    List<epubx.EpubTextContentFile> htmlContent,
  ) async {
    for (final htmlFile in htmlContent) {
      String htmlContent = htmlFile.Content ?? '';
      await writeStringToFile(htmlFile.FileName ?? '', htmlContent, folder);
    }
  }

  Future<void> extractCss(
    epubx.EpubContent content,
    String folder,
  ) async {
    List<epubx.EpubTextContentFile> cssFiles =
        content.Css?.values.toList() ?? [];
    for (var cssFile in cssFiles) {
      String cssContent = cssFile.Content ?? '';
      await writeStringToFile(cssFile.FileName ?? '', cssContent, folder);
    }
  }

  String getChapterNameByIndex(
    int index,
    List<epubx.EpubChapter> chapterList,
  ) {
    if (chapterList.length <= index) throw 'chapter index out of range';
    return chapterList[index].Title ?? '';
  }

  List<String> getChapterContentNameByIndex(
    int index,
    List<epubx.EpubNavigationPoint> pointList,
    Map<String, List<String>> chapterResourceMap,
  ) {
    if (chapterResourceMap.length <= index) throw 'chapter index out of range';
    return chapterResourceMap[pointList[index].hashCode.toString()] ?? [];
  }

  Future<void> _extractCover(
    String uid,
    epubx.Image? coverImage,
    List<epubx.EpubByteContentFile>? imageList,
  ) async {
    final path = '${pathManager.epubCoverPath}/$uid';
    final file = File(path);
    if (coverImage == null) {
      if (imageList == null || imageList.isEmpty) return;
      final firstImageFile = imageList.first;
      file.createSync(recursive: true);
      await file.writeAsBytes(firstImageFile.Content ?? []);
      return;
    } else {
      try {
        file.createSync(recursive: true);
        await file.writeAsBytes(encodePng(coverImage));
      } catch (e, stackTrace) {
        errorLogger.logError(e, stackTrace);
      }
    }
  }

  Future<void> _extractEpubBackup(File epub, String uid) async {
    final path = '${pathManager.backupPath}$uid';
    final backup = File(path);
    backup.createSync(recursive: true);
    await backup.writeAsBytes(epub.readAsBytesSync());
    return;
  }

  Future<void> deleteEpubBook(EpubManageData epubData) async {
    final coverFile = '${pathManager.epubCoverPath}${epubData.uid}';
    final cover = File(coverFile);
    if (cover.existsSync()) {
      cover.deleteSync();
    }
    final backupFile = '${pathManager.backupPath}/${epubData.uid}';
    final backup = File(backupFile);
    if (backup.existsSync()) {
      backup.deleteSync();
    }
    final path3 = '${pathManager.parseDirPath}/${epubData.uid}';
    final parseDir = Directory(path3);
    if (parseDir.existsSync()) {
      parseDir.deleteSync(recursive: true);
    }
  }

  void updateProgress(NovelType type, {int? progress = 0, String? message}) {
    if (type != NovelType.local) return;
    if (progress == 0) {
      globalBloc
          .add(GlobalEvent.startProgress(ProgressType.parsingEpub, message!));
    } else if (progress == 100) {
      globalBloc.add(const GlobalEvent.endProgress(ProgressType.parsingEpub));
    } else {
      globalBloc.add(GlobalEvent.updateProgress(
          ProgressType.parsingEpub, progress!, message!));
    }
  }
}

extension EpubNavigationPointExt on epubx.EpubNavigationPoint {
  String? get sourceName {
    return Content?.Source?.split('#').first;
  }
}
