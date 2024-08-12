import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/global/global_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/local_file/local_file_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = Talker();
late SharedPreferences prefs;
late Size screenSize;
late double appBarHeight;

final globalBloc = GlobalBloc();
final localFileCubit = LocalFileCubit();

void initScreenSize(BuildContext context) {
  screenSize = MediaQuery.sizeOf(context);
  appBarHeight = MediaQueryData.fromView(View.of(context)).padding.top;
}

GlobalBloc readGlobalBloc(BuildContext context) => context.read<GlobalBloc>();
EpubViewerBloc readEpubViewerBloc(BuildContext context) =>
    context.read<EpubViewerBloc>();

LocalFileCubit readLocalFileCubit(BuildContext context) =>
    context.read<LocalFileCubit>();
