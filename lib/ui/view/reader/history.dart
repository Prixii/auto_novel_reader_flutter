import 'package:auto_novel_reader_flutter/bloc/history/history_cubit.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(),
      child: readUserCubit(context).isSignIn
          ? const HistoryBody()
          : const Center(
              child: Text(
              '未登录',
            )),
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

  late PageLoader<WebNovelOutline, List<WebNovelOutline>> pageLoader;
  var searchData = const HistorySearchData();

  @override
  void initState() {
    super.initState();
    pageLoader = PageLoader(
        size: searchData.pageSize,
        initPage: 0,
        pageSetter: (newPage) => searchData = searchData.copyWith(
              page: newPage,
            ),
        loader: () async => _search(),
        dataGetter: (result) => result,
        onLoadSucceed: (outlines) {
          final cubit = readHistoryCubit(context);
          cubit.setHistoryOutlines(outlines);
          cubit.setLoadingStatus({RequestLabel.loadHistory: null});
        },
        onLoadFailed: (e, stackTrace) {
          errorLogger.logError(e, stackTrace);
          readHistoryCubit(context).setLoadingStatus(
            {
              RequestLabel.loadHistory: e is ServerException
                  ? LoadingStatus.serverError
                  : LoadingStatus.failed
            },
          );
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageLoader.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels > metrics.maxScrollExtent - 60) {
            if (shouldLoadMore && scrollDirection == ScrollDirection.forward) {
              shouldLoadMore = false;
              pageLoader.loadMore();
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
        onRefresh: () async => await pageLoader.refresh(),
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
                _buildIndicator(),
              ],
            )),
      ),
    );
  }

  Widget _buildIndicator() {
    return BlocSelector<HistoryCubit, HistoryState, LoadingStatus?>(
      selector: (state) {
        return state.loadingStatusMap[RequestLabel.loadHistory];
      },
      builder: (context, state) {
        return TimeoutInfoContainer(
          status: state,
          onRetry: () => doRefresh(),
          child: Container(),
        );
      },
    );
  }

  Future<List<WebNovelOutline>> _search() {
    final cubit = readHistoryCubit(context);
    cubit.setLoadingStatus({RequestLabel.loadHistory: LoadingStatus.loading});
    cubit.setHistoryOutlines([]);
    try {
      return requestHistory(searchData);
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      cubit.setLoadingStatus(
        {
          RequestLabel.loadHistory: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      );
      return Future.value([]);
    }
  }

  Future<void> doRefresh() async {
    final cubit = readHistoryCubit(context);
    try {
      cubit.setHistoryOutlines([]);
      cubit.setLoadingStatus({RequestLabel.loadHistory: LoadingStatus.loading});
      await pageLoader.refresh();
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      cubit.setLoadingStatus(
        {
          RequestLabel.loadHistory: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      );
    }
  }
}
