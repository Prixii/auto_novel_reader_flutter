import 'package:auto_novel_reader_flutter/util/error_logger.dart';

class PageLoader<T, R> {
  ///
  /// 分页加载小助手
  ///
  /// - [T] 数据类型
  /// - [R] 返回数据类型
  /// - [pageSetter] 用于给请求的 data 设置当前页码
  /// - [dataGetter] 用于从 response 中获取返回数据
  /// - [onLoadSucceed] 用于加载成功后的回调
  PageLoader({
    required this.pageSetter,
    required this.loader,
    required this.dataGetter,
    required this.onLoadSucceed,
    this.initPage = 0,
    this.size = 10,
  }) {
    currentPage = initPage;
  }

  List<T> dataList = [];
  bool isLoading = false;
  bool haveMore = true;
  int currentPage = 0;
  final int initPage;
  final int size;
  final Future<R> Function() loader;
  final Function(int) pageSetter;
  final List<T> Function(R) dataGetter;
  final Function(List<T>) onLoadSucceed;

  Future<void> loadMore() async {
    pageSetter.call(currentPage);
    if (!haveMore || isLoading) return;
    haveMore = false;
    isLoading = true;
    return loader.call().then(
      (response) {
        try {
          final newData = dataGetter(response);
          currentPage += 1;
          haveMore = (newData.length == size);
          dataList = [...dataList, ...newData];
          afterLoad();
        } catch (e, stackTrace) {
          errorLogger.logError(e, stackTrace);
        }
      },
      onError: (error) {
        haveMore = false;
        throw error;
      },
    ).whenComplete(() {
      isLoading = false;
    });
  }

  Future<void> refresh() async {
    currentPage = initPage;
    dataList = [];
    haveMore = true;
    await loadMore();
  }

  Future<void> loadAll() async {
    while (haveMore) {
      await loadMore();
    }
  }

  void afterLoad() {
    onLoadSucceed(dataList);
  }
}
