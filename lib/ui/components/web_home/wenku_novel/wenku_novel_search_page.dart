import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel/wenku_search_widget.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WenkuNovelSearchPage extends StatefulWidget {
  const WenkuNovelSearchPage({super.key});

  @override
  State<WenkuNovelSearchPage> createState() => _WenkuNovelSearchPageState();
}

class _WenkuNovelSearchPageState extends State<WenkuNovelSearchPage> {
  late TextEditingController _searchController;
  late RadioFilterController _levelController;
  late PageLoader<WenkuNovelOutline, List<WenkuNovelOutline>> pageLoader;

  var searchData = const WenkuSearchData();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _levelController = RadioFilterController(
      defaultOptionName: WenkuNovelLevel.values.first.zhName,
    );
    pageLoader = PageLoader(
        size: searchData.pageSize,
        initPage: 0,
        pageSetter: (newPage) => searchData = searchData.copyWith(
              page: newPage,
              level: WenkuNovelLevel.indexByZhName(_levelController.optionName),
            ),
        loader: () async => _search(),
        dataGetter: (result) => result,
        onLoadSucceed: (outlines) {
          final bloc = readWenkuHomeBloc(context);
          bloc.add(WenkuHomeEvent.setWenkuNovelOutlines(outlines));
          bloc.add(const WenkuHomeEvent.setLoadingStatus(
              {RequestLabel.searchWenku: null}));
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<WenkuHomeBloc>().state.wenkuNovelSearchResult.isEmpty) {
        doRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WenkuNovelDtoList(
          onLoadMore: () => pageLoader.loadMore(),
          onRefresh: doRefresh,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: WenkuSearchWidget(
            onSearch: () async => await doRefresh(),
            searchController: _searchController,
            levelController: _levelController,
          ),
        ),
      ],
    );
  }

  Future<List<WenkuNovelOutline>> _search() {
    readWenkuHomeBloc(context).add(const WenkuHomeEvent.setLoadingStatus(
        {RequestLabel.searchWenku: LoadingStatus.loading}));
    try {
      searchData = searchData.copyWith(
        query: _searchController.text,
      );
      return loadPagedWenkuOutlines(searchData);
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      throw Exception(e);
    }
  }

  Future<void> doRefresh() async {
    final bloc = readWenkuHomeBloc(context);
    try {
      bloc.add(const WenkuHomeEvent.setWenkuNovelOutlines([]));
      bloc.add(const WenkuHomeEvent.setLoadingStatus(
          {RequestLabel.searchWenku: LoadingStatus.loading}));
      await pageLoader.refresh();
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      bloc.add(WenkuHomeEvent.setLoadingStatus(
        {
          RequestLabel.searchWenku: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      ));
    }
  }
}

class WenkuNovelDtoList extends StatefulWidget {
  const WenkuNovelDtoList({
    super.key,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final Function onLoadMore;
  final Function onRefresh;

  @override
  State<WenkuNovelDtoList> createState() => _WenkuNovelDtoListState();
}

class _WenkuNovelDtoListState extends State<WenkuNovelDtoList> {
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
          child: BlocSelector<WenkuHomeBloc, WenkuHomeState,
              List<WenkuNovelOutline>>(
            selector: (state) {
              return state.wenkuNovelSearchResult;
            },
            builder: (context, wenkuNovels) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WenkuNovelList(wenkuNovels: wenkuNovels),
                  _buildIndicator()
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, LoadingStatus?>(
      selector: (state) {
        return state.loadingStatusMap[RequestLabel.searchWenku];
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
