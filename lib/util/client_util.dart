import 'dart:math';

import 'package:auto_novel_reader_flutter/bloc/config/config_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/local_file/local_file_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = Talker();
late SharedPreferences prefs;
late Size screenSize;
late double appBarHeight;
late Color errorContainerColor;
late Color onErrorContainerColor;

final globalBloc = GlobalBloc();
final localFileCubit = LocalFileCubit();
final epubViewerBloc = EpubViewerBloc();
final configCubit = ConfigCubit();
final userCubit = UserCubit();

void initScreenSize(BuildContext context) {
  screenSize = MediaQuery.sizeOf(context);
  appBarHeight = MediaQueryData.fromView(View.of(context)).padding.top;
}

void initColor(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  errorContainerColor = colorScheme.errorContainer;
  onErrorContainerColor = colorScheme.onErrorContainer;
}

void showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    textColor: onErrorContainerColor,
    backgroundColor: errorContainerColor,
  );
}

GlobalBloc readGlobalBloc(BuildContext context) => context.read<GlobalBloc>();
EpubViewerBloc readEpubViewerBloc(BuildContext context) =>
    context.read<EpubViewerBloc>();

LocalFileCubit readLocalFileCubit(BuildContext context) =>
    context.read<LocalFileCubit>();
ConfigCubit readConfigCubit(BuildContext context) =>
    context.read<ConfigCubit>();

UserCubit readUserCubit(BuildContext context) => context.read<UserCubit>();

Color getRandomDarkColor() {
  final random = Random();
  const maxValue = 128;
  final r = random.nextInt(maxValue);
  final g = random.nextInt(maxValue);
  final b = random.nextInt(maxValue);
  return Color.fromARGB(255, r, g, b);
}
