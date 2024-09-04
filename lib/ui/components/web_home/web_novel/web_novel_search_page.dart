import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/web_search_widget.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: WebSearchWidget(),
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
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 68),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocSelector<WebHomeBloc, WebHomeState, List<WebNovelOutline>>(
            selector: (state) {
              return state.webNovelSearchResult;
            },
            builder: (context, webNovels) {
              return AnimationLimiter(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      AnimationConfiguration.staggeredGrid(
                    duration: const Duration(milliseconds: 375),
                    position: index,
                    columnCount: 2,
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: WebNovelTile(webNovel: webNovels[index]),
                      ),
                    ),
                  ),
                  itemCount: webNovels.length,
                ),
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
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels + 128 >=
        _scrollController.position.maxScrollExtent) {
      _onScrollToBottom();
    }
  }

  void _onScrollToBottom() {
    readWebHomeBloc(context).add(const WebHomeEvent.loadNextPageWeb());
  }
}
