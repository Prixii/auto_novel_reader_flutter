import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/favored/favored_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/selector.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class FavoredView extends StatelessWidget {
  const FavoredView({super.key});

  @override
  Widget build(BuildContext context) {
    // readFavoredCubit(context).setFavored(
    //   type: NovelType.web,
    //   favored: Favored.createDefault(),
    // );
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) {
        return state.token != null;
      },
      builder: (context, state) {
        return !state
            ? const Center(child: Text('未登录'))
            : Stack(
                children: [
                  const FavoredBody(),
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
          child: Selector(
              onTap: (_, index) => readFavoredCubit(context)
                  .setFavored(type: NovelType.values[index]),
              tabs: [NovelType.web.zhName, NovelType.wenku.zhName]),
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
                        return Selector(
                            onTap: (_, index) => readFavoredCubit(context)
                                .setFavored(favored: favoredListWeb[index]),
                            tabs: favoredListWeb.map((e) => e.title).toList());
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
                        return Selector(
                            onTap: (_, index) => readFavoredCubit(context)
                                .setFavored(favored: favoredListWenku[index]),
                            tabs:
                                favoredListWenku.map((e) => e.title).toList());
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Selector(
              onTap: (_, index) => readFavoredCubit(context)
                  .setFavored(sortType: SearchSortType.values[index]),
              tabs: SearchSortType.values.map((e) => e.zhName).toList()),
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
            color: Theme.of(context).colorScheme.surface,
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
}

class FavoredBody extends StatefulWidget {
  const FavoredBody({
    super.key,
  });

  @override
  State<FavoredBody> createState() => _FavoredBodyState();
}

class _FavoredBodyState extends State<FavoredBody> {
  var scrollDirection = ScrollDirection.forward;
  var shouldLoadMore = false;

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
            if (shouldLoadMore && scrollDirection == ScrollDirection.forward) {
              shouldLoadMore = false;
              talker.debug('load next page!');
              readFavoredCubit(context).loadNextPage();
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
        selector: (state) {
          final type = state.currentType;
          final favored = state.currentFavored ?? Favored.createDefault();
          if (type == NovelType.web) {
            final list =
                state.favoredWebNovelsMap[favored.id] ?? <WebNovelOutline>[];
            return (list, type);
          }
          if (type == NovelType.wenku) {
            final list = state.favoredWenkuNovelsMap[favored.id] ??
                <WenkuNovelOutline>[];
            return (list, type);
          }
          throw Exception('invalid novel type');
        },
        builder: (context, listData) {
          switch (listData.$2) {
            case NovelType.web:
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 48.0, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WebNovelList(
                        webNovels: listData.$1 as List<WebNovelOutline>),
                    _buildWebProgressIndicator(),
                  ],
                ),
              );
            case NovelType.wenku:
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 48.0, horizontal: 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  WenkuNovelList(
                      wenkuNovels: listData.$1 as List<WenkuNovelOutline>),
                  _buildWenkuProgressIndicator(),
                ]),
              );
            default:
              throw Exception('invalid novel type');
          }
        },
      ),
    );
  }

  Widget _buildWebProgressIndicator() {
    return BlocSelector<FavoredCubit, FavoredState, bool>(
      selector: (state) {
        final favored = state.currentFavored ?? Favored.createDefault();
        return state.isWebRequestingMap[favored.id] ?? false;
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
    );
  }

  Widget _buildWenkuProgressIndicator() {
    return BlocSelector<FavoredCubit, FavoredState, bool>(
      selector: (state) {
        final favored = state.currentFavored ?? Favored.createDefault();
        return state.isWenkuRequestingMap[favored.id] ?? false;
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
    );
  }
}
