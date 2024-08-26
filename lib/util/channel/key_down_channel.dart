import 'dart:async';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/services.dart';

EventChannel? eventChannel;
StreamSubscription<dynamic>? subscription;

// TODO 主动初始化 android EventChannel

void initKeyDownChannel() async {
  await Future.delayed(const Duration(milliseconds: 500), () {});
  talker.debug('initKeyDownChannel!');
  eventChannel =
      const EventChannel('auto_novel_reader_flutter/key_event_channel');
}

void subscribeVolumeKeyEvent() {
  if (configCubit.state.volumeKeyShift == false) return;
  if (subscription != null) return;
  subscription = eventChannel!.receiveBroadcastStream().listen((event) {
    try {
      switch (event as String) {
        case 'volumeDown':
          handleVolumeDown();
          return;
        case 'volumeUp':
          handleVolumeUp();
          return;
      }
    } catch (e) {
      talker.error('key code error: $e');
    }
  });
}

void unsubscribeVolumeKeyEvent() {
  subscription?.cancel();
  subscription = null;
}

void handleVolumeDown() {
  epubViewerBloc.add(const EpubViewerEvent.nextChapter());
}

void handleVolumeUp() {
  epubViewerBloc.add(const EpubViewerEvent.previousChapter());
}
