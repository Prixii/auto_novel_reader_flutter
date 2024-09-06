import 'dart:math';

import 'package:auto_novel_reader_flutter/bloc/comment/comment_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/config/config_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/download_cubit/download_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/history/history_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/local_file/local_file_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_cache/web_cache_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = Talker();
late Size screenSize;
late double appBarHeight;

final globalBloc = GlobalBloc();
final localFileCubit = LocalFileCubit();
final epubViewerBloc = EpubViewerBloc();
final configCubit = ConfigCubit();
final userCubit = UserCubit();
final webHomeBloc = WebHomeBloc();
final wenkuHomeBloc = WenkuHomeBloc();
final webCacheCubit = WebCacheCubit();
final downloadCubit = DownloadCubit();
final novelRankBloc = NovelRankBloc();
final favoredCubit = FavoredCubit();

GlobalBloc readGlobalBloc(BuildContext context) => context.read<GlobalBloc>();
EpubViewerBloc readEpubViewerBloc(BuildContext context) =>
    context.read<EpubViewerBloc>();
LocalFileCubit readLocalFileCubit(BuildContext context) =>
    context.read<LocalFileCubit>();
ConfigCubit readConfigCubit(BuildContext context) =>
    context.read<ConfigCubit>();
UserCubit readUserCubit(BuildContext context) => context.read<UserCubit>();
WebHomeBloc readWebHomeBloc(BuildContext context) =>
    context.read<WebHomeBloc>();
WebCacheCubit readWebCacheCubit(BuildContext context) =>
    context.read<WebCacheCubit>();
WenkuHomeBloc readWenkuHomeBloc(BuildContext context) =>
    context.read<WenkuHomeBloc>();
DownloadCubit readDownloadCubit(BuildContext context) =>
    context.read<DownloadCubit>();
NovelRankBloc readNovelRankBloc(BuildContext context) =>
    context.read<NovelRankBloc>();
FavoredCubit readFavoredCubit(BuildContext context) =>
    context.read<FavoredCubit>();
HistoryCubit readHistoryCubit(BuildContext context) =>
    context.read<HistoryCubit>();
CommentCubit readCommentCubit(BuildContext context) =>
    context.read<CommentCubit>();

void initScreenSize(BuildContext context) {
  screenSize = MediaQuery.sizeOf(context);
  appBarHeight = MediaQueryData.fromView(View.of(context)).padding.top;
}

void showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    textColor: styleManager.colorScheme.onErrorContainer,
    backgroundColor: styleManager.colorScheme.errorContainer,
  );
}

void showWarnToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    textColor: styleManager.onWarnContainer,
    backgroundColor: styleManager.warnContainer,
  );
}

void showSucceedToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    textColor: styleManager.onSucceedContainer,
    backgroundColor: styleManager.succeedContainer,
  );
}

String parseTimeStamp(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
  return date.toString().substring(0, 10);
}

String parseLargeNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else {
    return '$number';
  }
}

Color getRandomDarkColor() {
  final random = Random();
  const maxValue = 128;
  final r = random.nextInt(maxValue);
  final g = random.nextInt(maxValue);
  final b = random.nextInt(maxValue);
  return Color.fromARGB(255, r, g, b);
}

String formatTimestamp(int timestamp) {
  DateTime inputTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  DateTime now = DateTime.now();

  Duration difference = now.difference(inputTime);

  if (difference.inDays < 1) {
    return '今天 ${inputTime.hour}:${inputTime.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays < 30) {
    return '${difference.inDays}天前';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}月前';
  } else {
    return '${(difference.inDays / 365).floor()}年前';
  }
}
