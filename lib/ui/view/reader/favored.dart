import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/ui/components/favored/favored_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/selector.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class FavoredView extends StatefulWidget {
  const FavoredView({super.key});

  @override
  State<FavoredView> createState() => _FavoredViewState();
}

class _FavoredViewState extends State<FavoredView> {
  late PageLoader<WebNovelOutline, List<WebNovelOutline>> webPageLoader;
  late PageLoader<WenkuNovelOutline, List<WenkuNovelOutline>> wenkuPageLoader;

  late LoadFavoredData webFavoredData, wenkuFavoredData;

  @override
  void initState() {
    super.initState();
    webFavoredData = const LoadFavoredData();
    wenkuFavoredData = const LoadFavoredData();

    webPageLoader = PageLoader(
        size: webFavoredData.pageSize,
        initPage: 0,
        pageSetter: (newPage) => webFavoredData = webFavoredData.copyWith(
              page: newPage,
            ),
        loader: () async => _searchWeb(),
        dataGetter: (result) => result,
        onLoadSucceed: (outlines) {
          final cubit = readFavoredCubit(context);
          cubit.setFavoredNovelList(
            NovelType.web,
            webFavoredData.favoredId,
            webNovels: outlines,
          );
          cubit.setLoadingStatus({webFavoredKey: null});
        },
        onLoadFailed: (e, stackTrace) {
          errorLogger.logError(e, stackTrace);
          readFavoredCubit(context).setLoadingStatus(
            {
              webFavoredKey: e is ServerException
                  ? LoadingStatus.serverError
                  : LoadingStatus.failed
            },
          );
        });
    wenkuPageLoader = PageLoader(
        size: wenkuFavoredData.pageSize,
        initPage: 0,
        pageSetter: (newPage) => wenkuFavoredData = wenkuFavoredData.copyWith(
              page: newPage,
            ),
        loader: () async => _searchWenku(),
        dataGetter: (result) => result,
        onLoadSucceed: (outlines) {
          final cubit = readFavoredCubit(context);
          cubit.setFavoredNovelList(
            NovelType.wenku,
            wenkuFavoredData.favoredId,
            wenkuNovels: outlines,
          );
          cubit.setLoadingStatus({wenkuFavoredKey: null});
        },
        onLoadFailed: (e, stackTrace) {
          errorLogger.logError(e, stackTrace);
          readFavoredCubit(context).setLoadingStatus(
            {
              wenkuFavoredKey: e is ServerException
                  ? LoadingStatus.serverError
                  : LoadingStatus.failed
            },
          );
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      doRefreshWeb();
    });
  }

  Future<List<WebNovelOutline>> _searchWeb() async {
    final cubit = readFavoredCubit(context);
    try {
      cubit.setLoadingStatus({webFavoredKey: LoadingStatus.loading});
      final widgetContext = context;
      final newWebNovelList = await loadWebFavored(webFavoredData);
      if (widgetContext.mounted) {
        readFavoredCubit(widgetContext)
            .setNovelToFavoredIdMap(webOutlines: newWebNovelList);
      }
      return newWebNovelList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> doRefreshWeb() async {
    final cubit = readFavoredCubit(context);
    try {
      cubit.setFavoredNovelList(
        NovelType.web,
        webFavoredData.favoredId,
        webNovels: [],
      );
      await webPageLoader.refresh();
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      cubit.setLoadingStatus(
        {
          webFavoredKey: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      );
    }
  }

  Future<List<WenkuNovelOutline>> _searchWenku() async {
    final cubit = readFavoredCubit(context);
    try {
      cubit.setLoadingStatus({wenkuFavoredKey: LoadingStatus.loading});
      final widgetContext = context;
      final newWenkuNovelList = await loadWenkuFavored(wenkuFavoredData);
      if (widgetContext.mounted) {
        readFavoredCubit(widgetContext)
            .setNovelToFavoredIdMap(wenkuOutlines: newWenkuNovelList);
      }
      return newWenkuNovelList;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> doRefreshWenku() async {
    final cubit = readFavoredCubit(context);
    try {
      cubit.setFavoredNovelList(NovelType.wenku, wenkuFavoredData.favoredId,
          wenkuNovels: []);
      await wenkuPageLoader.refresh();
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      cubit.setLoadingStatus(
        {
          wenkuFavoredKey: e is ServerException
              ? LoadingStatus.serverError
              : LoadingStatus.failed
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) {
        return state.token != null;
      },
      builder: (context, state) {
        return !state
            ? const Center(child: Text('未登录'))
            : Stack(
                children: [
                  FavoredBody(
                    refreshWeb: doRefreshWeb,
                    refreshWenku: doRefreshWenku,
                    loadMoreWeb: webPageLoader.loadMore,
                    loadMoreWenku: wenkuPageLoader.loadMore,
                  ),
                  _buildFavoredSelector(context),
                  _buildAddFavoredButton(context),
                ],
              );
      },
    );
  }

  Widget _buildAddFavoredButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          onPressed: () async {
            _showFavoredManager(context);
          },
          tooltip: '收藏夹管理',
          child: const Icon(UniconsLine.folder_open),
        ),
      ),
    );
  }

  Widget _buildFavoredSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocSelector<FavoredCubit, FavoredState, NovelType>(
            selector: (state) {
              return state.currentType;
            },
            builder: (context, type) {
              return Selector(
                  value: type.zhName,
                  onTap: (index) => setFavored(type: NovelType.values[index]),
                  tabs: [NovelType.web.zhName, NovelType.wenku.zhName]);
            },
          ),
        ),
        Expanded(
          child: BlocSelector<FavoredCubit, FavoredState, NovelType>(
            selector: (state) {
              return state.currentType;
            },
            builder: (context, currentType) {
              return Stack(
                children: [
                  Visibility(
                    visible: currentType == NovelType.web,
                    child:
                        BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
                      selector: (state) {
                        final listWeb = state.favoredMap[NovelType.web];
                        final favoredListWeb =
                            (listWeb == null || listWeb.isEmpty)
                                ? <Favored>[Favored.createDefault()]
                                : listWeb;
                        return favoredListWeb;
                      },
                      builder: (context, favoredListWeb) {
                        return BlocSelector<FavoredCubit, FavoredState,
                            Favored>(
                          selector: (state) {
                            return state.currentFavored ??
                                Favored.createDefault();
                          },
                          builder: (context, currentFavored) {
                            return Selector(
                                value: currentFavored.title,
                                onTap: (index) =>
                                    setFavored(favored: favoredListWeb[index]),
                                tabs: favoredListWeb
                                    .map((e) => e.title)
                                    .toList());
                          },
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: currentType == NovelType.wenku,
                    child:
                        BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
                      selector: (state) {
                        final listWenku = state.favoredMap[NovelType.wenku];
                        final favoredListWenku =
                            (listWenku == null || listWenku.isEmpty)
                                ? <Favored>[Favored.createDefault()]
                                : listWenku;
                        return favoredListWenku;
                      },
                      builder: (context, favoredListWenku) {
                        return BlocSelector<FavoredCubit, FavoredState,
                            Favored>(
                          selector: (state) {
                            return state.currentFavored ??
                                Favored.createDefault();
                          },
                          builder: (context, currentFavored) {
                            return Selector(
                                value: currentFavored.title,
                                onTap: (index) => setFavored(
                                    favored: favoredListWenku[index]),
                                tabs: favoredListWenku
                                    .map((e) => e.title)
                                    .toList());
                          },
                        );
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
        Expanded(
          child: BlocSelector<FavoredCubit, FavoredState, SearchSortType>(
            selector: (state) {
              return state.searchSortType;
            },
            builder: (context, sort) {
              return Selector(
                  value: sort.zhName,
                  onTap: (index) =>
                      setFavored(sortType: SearchSortType.values[index]),
                  tabs: SearchSortType.values.map((e) => e.zhName).toList());
            },
          ),
        ),
      ],
    );
  }

  void _showFavoredManager(BuildContext widgetContext) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: widgetContext,
      constraints: BoxConstraints(
        minWidth: screenSize.width,
        maxHeight: screenSize.height * 0.8,
        minHeight: screenSize.height * 0.8,
      ),
      enableDrag: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: styleManager.colorScheme(context).surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: const FavoredManager(),
        );
      },
    );
  }

  void setFavored({
    NovelType? type,
    Favored? favored,
    SearchSortType? sortType,
  }) {
    if (type == null && favored == null && sortType == null) return;
    final cubit = readFavoredCubit(context);
    type = type ?? cubit.state.currentType;

    cubit.setFavored(sortType: sortType, type: type, favored: favored);
    if (type == NovelType.web) {
      if (favored?.id == webFavoredData.favoredId &&
          sortType == webFavoredData.sort) return;
      webFavoredData = webFavoredData.copyWith(
        favoredId: favored?.id ?? webFavoredData.favoredId,
        sort: sortType ?? webFavoredData.sort,
      );
      doRefreshWeb();
    } else if (type == NovelType.wenku) {
      if (favored?.id == wenkuFavoredData.favoredId &&
          sortType == wenkuFavoredData.sort) return;
      wenkuFavoredData = wenkuFavoredData.copyWith(
        favoredId: favored?.id ?? wenkuFavoredData.favoredId,
        sort: sortType ?? wenkuFavoredData.sort,
      );
      doRefreshWenku();
    }
  }

  String get wenkuFavoredKey => 'wenku-${wenkuFavoredData.favoredId}';
  String get webFavoredKey => 'web-${webFavoredData.favoredId}';
}

class FavoredBody extends StatefulWidget {
  const FavoredBody({
    super.key,
    required this.refreshWenku,
    required this.refreshWeb,
    required this.loadMoreWenku,
    required this.loadMoreWeb,
  });

  final Future<void> Function() refreshWenku, refreshWeb;
  final Future<void> Function() loadMoreWenku, loadMoreWeb;
  @override
  State<FavoredBody> createState() => _FavoredBodyState();
}

class _FavoredBodyState extends State<FavoredBody>
    with TickerProviderStateMixin {
  var scrollDirection = ScrollDirection.forward;
  var shouldLoadMore = false;

  @override
  void initState() {
    super.initState();
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
              final novelType = readFavoredCubit(context).state.currentType;

              novelType == NovelType.web
                  ? widget.loadMoreWeb()
                  : (novelType == NovelType.wenku)
                      ? widget.loadMoreWenku()
                      : null;
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
      child: BlocSelector<FavoredCubit, FavoredState, (List, NovelType)>(
          selector: (typeNovelData) {
        final type = typeNovelData.currentType;
        final favored = typeNovelData.currentFavored ?? Favored.createDefault();
        if (type == NovelType.web) {
          final list = typeNovelData.favoredWebNovelsMap[favored.id] ??
              <WebNovelOutline>[];
          return (list, type);
        }
        if (type == NovelType.wenku) {
          final list = typeNovelData.favoredWenkuNovelsMap[favored.id] ??
              <WenkuNovelOutline>[];
          return (list, type);
        }
        throw Exception('invalid novel type');
      }, builder: (context, listData) {
        final novelType = listData.$2;

        return BlocSelector<FavoredCubit, FavoredState, LoadingStatus?>(
          selector: (state) {
            final favoredKey = '${novelType.name}-${state.currentFavored?.id}';
            return state.loadingStatusMap[favoredKey];
          },
          builder: (context, state) {
            return RefreshList(
              loadingStatus: state,
              onRetry: () async {
                if (novelType == NovelType.web) {
                  await widget.refreshWeb();
                } else if (novelType == NovelType.wenku) {
                  await widget.refreshWenku();
                }
              },
              padding:
                  const EdgeInsets.symmetric(vertical: 48.0, horizontal: 8),
              child: _selectNovelList(novelType, listData),
            );
          },
        );
      }),
    );
  }

  StatelessWidget _selectNovelList(
      NovelType novelType, (List<dynamic>, NovelType) listData) {
    return novelType == NovelType.web
        ? WebNovelList(webNovels: listData.$1 as List<WebNovelOutline>)
        : (novelType == NovelType.wenku
            ? WenkuNovelList(
                wenkuNovels: listData.$1 as List<WenkuNovelOutline>)
            : throw Exception('invalid novel type'));
  }
}
