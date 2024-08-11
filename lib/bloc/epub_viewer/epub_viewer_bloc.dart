import 'dart:io';

import 'package:auto_novel_reader_flutter/ui/view/reader/epub_reader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:auto_novel_reader_flutter/util/html_util.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'epub_viewer_event.dart';
part 'epub_viewer_state.dart';
part 'epub_viewer_bloc.freezed.dart';

class EpubViewerBloc extends Bloc<EpubViewerEvent, EpubViewerState> {
  EpubViewerBloc() : super(const _Initial()) {
    on<EpubViewerEvent>((event, emit) async {
      await event.map(
        open: (event) async => await _onOpen(event, emit),
        nextChapter: (event) async => await _onNextChapter(event, emit),
        previousChapter: (event) async => await _onPreviousChapter(event, emit),
        goToChapter: (event) async => await _onGoToChapter(event, emit),
        clickUrl: (event) async => await _onClickUrl(event, emit),
      );
    });
  }

  _onOpen(_Open event, Emitter<EpubViewerState> emit) async {
    await epubUtil.parseEpub(event.epub);
    emit(state.copyWith(
      title: epubUtil.title,
      author: epubUtil.authorList.firstOrNull ?? '',
    ));
    if (event.context.mounted) {
      Navigator.of(event.context).push(
          MaterialPageRoute(builder: (context) => const EpubReaderView()));
    }

    final htmlData = await _loadHTMLFile();
    emit(state.copyWith(htmlData: htmlData));
  }

  _onNextChapter(_NextChapter event, Emitter<EpubViewerState> emit) async {}

  _onPreviousChapter(
      _PreviousChapter event, Emitter<EpubViewerState> emit) async {}

  _onGoToChapter(_GoToChapter event, Emitter<EpubViewerState> emit) async {}

  Future<String> _loadHTMLFile() async {
    final currentPath = epubUtil.currentPath;
    final pointList = epubUtil.pointList;
    if (currentPath == null || pointList.length < state.currentPage) return '';

    final htmlFileName = epubUtil.pointList[state.currentPage].sourceName;
    if (htmlFileName == null) return '';

    final rawHtml = await File('$currentPath/$htmlFileName').readAsString();
    final redirectedHtml =
        htmlUtil.redirectSource(rawHtml, epubUtil.currentPath ?? '');
    final htmlData = htmlUtil.removeHeadSection(redirectedHtml);
    talker.debug('htmlContent: $htmlData');
    return htmlData;
  }

  _onClickUrl(_ClickUrl event, Emitter<EpubViewerState> emit) {
    /// TODO 点击事件
    /// 检查 point 目录
    /// 检查 html 文件， 打开 html 文件
    /// 修改 page
  }
}
