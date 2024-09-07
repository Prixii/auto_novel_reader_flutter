import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/web_search_widget.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebNovelSearchPage extends StatelessWidget {
  const WebNovelSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<WebHomeBloc>().state.webNovelSearchResult.isEmpty) {
      readWebHomeBloc(context).add(const WebHomeEvent.searchWeb());
    }
    return const Stack(
      children: [
        WebNovelDtoList(),
        Align(
          alignment: Alignment.topCenter,
          child: WebSearchWidget(),
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels > metrics.maxScrollExtent - 60) {
              if (shouldLoadMore &&
                  scrollDirection == ScrollDirection.forward) {
                shouldLoadMore = false;
                talker.debug('load next page!');
                readWebHomeBloc(context)
                    .add(const WebHomeEvent.loadNextPageWeb());
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
              BlocSelector<WebHomeBloc, WebHomeState, List<WebNovelOutline>>(
                selector: (state) {
                  return state.webNovelSearchResult;
                },
                builder: (context, webNovels) {
                  return WebNovelList(
                    webNovels: webNovels,
                  );
                },
              ),
              BlocSelector<WebHomeBloc, WebHomeState, bool>(
                selector: (state) {
                  return state.searchingWeb;
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
        ));
  }
}
