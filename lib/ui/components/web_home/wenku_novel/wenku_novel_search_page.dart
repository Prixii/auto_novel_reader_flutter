import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel/wenku_search_widget.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WenkuNovelSearchPage extends StatelessWidget {
  const WenkuNovelSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<WenkuHomeBloc>().state.wenkuNovelSearchResult.isEmpty) {
      readWenkuHomeBloc(context).add(const WenkuHomeEvent.searchWenku());
    }
    return const Stack(
      children: [
        WebNovelDtoList(),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: WenkuSearchWidget(),
          ),
        ),
      ],
    );
  }
}

class WebNovelDtoList extends StatefulWidget {
  const WebNovelDtoList({
    super.key,
  });

  @override
  State<WebNovelDtoList> createState() => _WebNovelDtoListState();
}

class _WebNovelDtoListState extends State<WebNovelDtoList> {
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
              readWenkuHomeBloc(context)
                  .add(const WenkuHomeEvent.loadNextPageWenku());
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 68),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocSelector<WenkuHomeBloc, WenkuHomeState,
                List<WenkuNovelOutline>>(
              selector: (state) {
                return state.wenkuNovelSearchResult;
              },
              builder: (context, wenkuNovels) {
                return WenkuNovelList(wenkuNovels: wenkuNovels);
              },
            ),
            BlocSelector<WenkuHomeBloc, WenkuHomeState, bool>(
              selector: (state) {
                return state.searchingWenku;
              },
              builder: (context, state) {
                return SizedBox(
                  height: 64,
                  child: Center(
                    child: Visibility(
                      visible: state,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
