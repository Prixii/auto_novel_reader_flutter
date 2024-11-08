import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
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
  late PageLoader<WenkuNovelOutline, List<WenkuNovelOutline>> pageLoader;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final bloc = readWenkuHomeBloc(context);
    pageLoader = PageLoader(
        size: bloc.searchData.pageSize,
        initPage: 0,
        pageSetter: (newPage) {
          final searchData = bloc.searchData.copyWith(page: newPage);
          bloc.add(WenkuHomeEvent.setSearchData(searchData));
        },
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
          ),
        ),
      ],
    );
  }

  Future<List<WenkuNovelOutline>> _search() async {
    final bloc = readWenkuHomeBloc(context);
    bloc.add(const WenkuHomeEvent.setLoadingStatus(
        {RequestLabel.searchWenku: LoadingStatus.loading}));
    // HACK 和 bloc 数据不同步
    await Future.delayed(const Duration(milliseconds: 100), () {});
    try {
      final searchData = bloc.searchData.copyWith(
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

  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;

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
      child: _buildWenkuList(),
    );
  }

  Widget _buildWenkuList() {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, List<WenkuNovelOutline>>(
      selector: (state) {
        return state.wenkuNovelSearchResult;
      },
      builder: (context, wenkuNovels) {
        return BlocSelector<WenkuHomeBloc, WenkuHomeState, LoadingStatus?>(
          selector: (state) {
            return state.loadingStatusMap[RequestLabel.searchWenku];
          },
          builder: (context, state) {
            return RefreshList(
                loadingStatus: state,
                onRetry: widget.onRefresh,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 68,
                ),
                child: WenkuNovelList(wenkuNovels: wenkuNovels));
          },
        );
      },
    );
  }
}
