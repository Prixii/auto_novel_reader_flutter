import 'dart:io';

import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/epub_reader.dart';
import 'package:auto_novel_reader_flutter/util/channel/key_down_channel.dart';
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
        clickUrl: (event) async => await _onClickUrl(event, emit),
        close: (event) async => await _onClose(event, emit),
        openSettings: (event) async => await _onOpenSettings(event, emit),
        setScrollController: (event) async =>
            await _onSetScrollController(event, emit),
        switchChapter: (event) async => await _onSwitchChapter(event, emit),
      );
    });
  }

  _onOpen(_Open event, Emitter<EpubViewerState> emit) async {
    final data = event.epubManageData;
    emit(state.copyWith(
      epubManageData: data,
      chapterResourceMap: data.chapterResourceMap ?? {},
    ));
    if (event.context.mounted) {
      Navigator.of(event.context).push(
          MaterialPageRoute(builder: (context) => const EpubReaderView()));
    }
    subscribeVolumeKeyEvent();
    add(EpubViewerEvent.switchChapter(
      data.chapter ?? 0,
      data.progress ?? 0,
    ));
  }

  _onNextChapter(_NextChapter event, Emitter<EpubViewerState> emit) async {
    final newIndex = state.currentChapterIndex + 1;
    if (newIndex >= state.chapterResourceMap.length) return;
    add(EpubViewerEvent.switchChapter(newIndex, 0));
  }

  _onPreviousChapter(
      _PreviousChapter event, Emitter<EpubViewerState> emit) async {
    final newIndex = state.currentChapterIndex - 1;
    if (newIndex < 0) return;
    add(EpubViewerEvent.switchChapter(newIndex, 1));
  }

  _onClickUrl(_ClickUrl event, Emitter<EpubViewerState> emit) {
    /// TODO 点击事件
    /// 检查 point 目录
    /// 检查 html 文件， 打开 html 文件
    /// 修改 page
  }

  _onClose(_Close event, Emitter<EpubViewerState> emit) {
    if (!state.canPop || state.epubManageData == null) return;
    final newEpubManageData = state.epubManageData!.copyWith(
      progress: event.progress,
      chapter: state.currentChapterIndex,
    );
    emit(const EpubViewerState.initial());
    localFileCubit.updateEpubManageData(newEpubManageData);
    unsubscribeVolumeKeyEvent();
  }

  _onOpenSettings(_OpenSettings event, Emitter<EpubViewerState> emit) {}

  _onSetScrollController(
      _SetScrollController event, Emitter<EpubViewerState> emit) {
    emit(state.copyWith(scrollController: event.controller));
    state.scrollController!.jumpTo(
        state.scrollController!.position.maxScrollExtent *
            (state.epubManageData!.progress ?? 0));
  }

  _onSwitchChapter(_SwitchChapter event, Emitter<EpubViewerState> emit) async {
    emit(state.copyWith(
        currentChapterIndex: event.index,
        htmlData: [],
        canPop: event.canPop ?? true));
    await for (final htmlPartList in _loadHTMLFile(event.index)) {
      emit(state.copyWith(
          htmlData: [...state.htmlData, ...htmlPartList], canPop: true));
    }
    if (state.scrollController == null) return;
    state.scrollController?.jumpTo(
        state.scrollController!.position.maxScrollExtent * event.readProgress);
  }

  Stream<List<String>> _loadHTMLFile(int chapterIndex) async* {
    final currentPath = epubUtil.getPathByUid(state.epubManageData!.uid ?? '');
    final chapterResourceEntries =
        state.epubManageData!.chapterResourceMap!.entries.toList();
    if (chapterResourceEntries.length < chapterIndex) return;

    final resourceList = chapterResourceEntries[chapterIndex].value;

    final uid = state.epubManageData!.uid;
    if (uid == null) {
      talker.error('bad epubManageData: ${state.epubManageData}');
      throw Exception('bad epubManageData');
    }
    final path = epubUtil.getPathByUid(uid);
    for (var htmlFileName in resourceList) {
      final rawHtml = await File('$currentPath/$htmlFileName').readAsString();

      yield htmlUtil.pretreatHtml(rawHtml, path);
    }
  }
}
