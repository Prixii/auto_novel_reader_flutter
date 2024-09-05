import 'package:auto_novel_reader_flutter/bloc/history/history_cubit.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(),
      child: const HistoryBody(),
    );
  }
}

class HistoryBody extends StatelessWidget {
  const HistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: BlocSelector<HistoryCubit, HistoryState, List<WebNovelOutline>>(
        selector: (state) {
          return state.histories;
        },
        builder: (context, state) {
          return WebNovelList(
            webNovels: state,
            listMode: true,
          );
        },
      ),
    );
  }
}
