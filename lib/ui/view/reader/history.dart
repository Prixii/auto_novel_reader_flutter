import 'package:auto_novel_reader_flutter/bloc/history/history_cubit.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class HistoryBody extends StatefulWidget {
  const HistoryBody({super.key});

  @override
  State<HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<HistoryBody> {
  var scrollDirection = ScrollDirection.forward;
  var shouldLoadMore = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels > metrics.maxScrollExtent - 60) {
            if (shouldLoadMore && scrollDirection == ScrollDirection.forward) {
              shouldLoadMore = false;
              talker.debug('load next page!');
              readHistoryCubit(context).loadNextPage();
            }
          } else {
            shouldLoadMore = true;
          }
        }
        if (notification is ScrollUpdateNotification) {
          final delta = notification.dragDetails;
          if (delta != null) {
            scrollDirection = delta.delta.dy > 0
                ? ScrollDirection.reverse
                : ScrollDirection.forward;
          }
        }
        return false;
      },
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocSelector<HistoryCubit, HistoryState, List<WebNovelOutline>>(
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
              BlocSelector<HistoryCubit, HistoryState, bool>(
                selector: (state) {
                  return state.isRequesting;
                },
                builder: (context, isRequesting) {
                  return Visibility(
                    visible: isRequesting,
                    child: const SizedBox(
                      height: 64,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
