import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/check_filter.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/web_search_widget.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebNovelSearchPage extends StatefulWidget {
  const WebNovelSearchPage({super.key});

  @override
  State<WebNovelSearchPage> createState() => _WebNovelSearchPageState();
}

class _WebNovelSearchPageState extends State<WebNovelSearchPage> {
  late CheckFilterController<NovelProvider> _checkFilterController;
  late TextEditingController _searchController;
  late PageLoader<WebNovelOutline, List<WebNovelOutline>> pageLoader;

  @override
  void initState() {
    super.initState();
    _checkFilterController = CheckFilterController();
    _searchController = TextEditingController();

    final bloc = readWebHomeBloc(context);
    final isOldAss = readUserCubit(context).isOldAss;
    if (isOldAss) {
      bloc.add(WebHomeEvent.setSearchData(
          bloc.searchData.copyWith(level: WebNovelLevel.all)));
    }

    pageLoader = PageLoader(
        size: bloc.searchData.pageSize,
        initPage: 0,
        pageSetter: (newPage) {
          bloc.add(WebHomeEvent.setSearchData(
            bloc.searchData.copyWith(
              page: newPage,
              query: _searchController.text,
            ),
          ));
        },
        loader: () async => _search(),
        dataGetter: (result) => result,
        onLoadSucceed: (outlines) {
          final bloc = readWebHomeBloc(context);
          bloc.add(WebHomeEvent.setWebNovelOutlines(outlines));
          bloc.add(const WebHomeEvent.setLoadingStatus(
              {RequestLabel.searchWeb: null}));
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<WebHomeBloc>().state.webNovelSearchResult.isEmpty) {
        doRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebNovelDtoList(
          onLoadMore: () => pageLoader.loadMore(),
          onRefresh: doRefresh,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: WebSearchWidget(
            searchController: _searchController,
            checkFilterController: _checkFilterController,
            onSearch: () async => await doRefresh(),
          ),
        ),
      ],
    );
  }

  Future<List<WebNovelOutline>> _search() {
    final bloc = readWebHomeBloc(context);
    bloc.add(const WebHomeEvent.setLoadingStatus(
        {RequestLabel.searchWeb: LoadingStatus.loading}));
    try {
      final searchData = bloc.searchData.copyWith(
        query: _searchController.text,
      );
      bloc.add(WebHomeEvent.setSearchData(searchData));
      return loadPagedWebOutlines(searchData);
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      bloc.add(WebHomeEvent.setLoadingStatus(
        {
          RequestLabel.searchWeb: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      ));
      return Future.value([]);
    }
  }

  Future<void> doRefresh() async {
    final bloc = readWebHomeBloc(context);
    try {
      bloc.add(const WebHomeEvent.setWebNovelOutlines([]));
      bloc.add(const WebHomeEvent.setLoadingStatus(
          {RequestLabel.searchWeb: LoadingStatus.loading}));
      await pageLoader.refresh();
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      bloc.add(WebHomeEvent.setLoadingStatus(
        {
          RequestLabel.searchWeb: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      ));
    }
  }
}

class WebNovelDtoList extends StatefulWidget {
  const WebNovelDtoList({
    super.key,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final Function onLoadMore;
  final Function onRefresh;

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
                widget.onLoadMore.call();
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
        child: RefreshIndicator(
          onRefresh: () async => await widget.onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 68),
            child:
                BlocSelector<WebHomeBloc, WebHomeState, List<WebNovelOutline>>(
              selector: (state) {
                return state.webNovelSearchResult;
              },
              builder: (context, webNovels) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WebNovelList(webNovels: webNovels),
                    _buildIndicator()
                  ],
                );
              },
            ),
          ),
        ));
  }

  Widget _buildIndicator() {
    return BlocSelector<WebHomeBloc, WebHomeState, LoadingStatus?>(
      selector: (state) {
        return state.loadingStatusMap[RequestLabel.searchWeb];
      },
      builder: (context, state) {
        return TimeoutInfoContainer(
          status: state,
          onRetry: () => widget.onRefresh(),
          child: Container(),
        );
      },
    );
  }
}
