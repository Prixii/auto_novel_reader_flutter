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
        close: (event) async => await _onClose(event, emit),
        openSettings: (event) async => await _onOpenSettings(event, emit),
        setScrollController: (event) async =>
            await _onSetScrollController(event, emit),
        updateReadingProgress: (event) async =>
            await _onUpdateReadingProgress(event, emit),
        switchChapter: (event) async => await _onSwitchChapter(event, emit),
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
    add(const EpubViewerEvent.switchChapter(0));
  }

  _onNextChapter(_NextChapter event, Emitter<EpubViewerState> emit) async {
    final newIndex = state.currentChapterIndex + 1;
    if (newIndex >= epubUtil.pointList.length) return;
    add(EpubViewerEvent.switchChapter(newIndex));
  }

  _onPreviousChapter(
      _PreviousChapter event, Emitter<EpubViewerState> emit) async {
    final newIndex = state.currentChapterIndex - 1;
    if (newIndex < 0) return;
    add(EpubViewerEvent.switchChapter(newIndex));
  }

  _onGoToChapter(_GoToChapter event, Emitter<EpubViewerState> emit) async {}

  _onClickUrl(_ClickUrl event, Emitter<EpubViewerState> emit) {
    /// TODO 点击事件
    /// 检查 point 目录
    /// 检查 html 文件， 打开 html 文件
    /// 修改 page
  }

  _onClose(_Close event, Emitter<EpubViewerState> emit) {
    emit(const EpubViewerState.initial());
  }

  _onOpenSettings(_OpenSettings event, Emitter<EpubViewerState> emit) {}

  _onSetScrollController(
      _SetScrollController event, Emitter<EpubViewerState> emit) {
    emit(state.copyWith(scrollController: event.controller));
  }

  _onUpdateReadingProgress(
      _UpdateReadingProgress event, Emitter<EpubViewerState> emit) {}

  _onSwitchChapter(_SwitchChapter event, Emitter<EpubViewerState> emit) async {
    emit(state.copyWith(currentChapterIndex: event.index, htmlData: []));
    await for (final htmlPartList in _loadHTMLFile(event.index)) {
      emit(state.copyWith(htmlData: [...state.htmlData, ...htmlPartList]));
      talker.info('new paras count: ${state.htmlData.length}');
    }
  }

  Stream<List<String>> _loadHTMLFile(int chapterIndex) async* {
    final currentPath = epubUtil.currentPath;
    final pointList = epubUtil.pointList;
    if (currentPath == null || pointList.length < chapterIndex) return;

    final resourceList = epubUtil.getChapterContentNameByIndex(chapterIndex);

    for (var htmlFileName in resourceList) {
      final rawHtml = await File('$currentPath/$htmlFileName').readAsString();

      yield htmlUtil.pretreatHtml(rawHtml, epubUtil.currentPath ?? '');
    }
  }
}
