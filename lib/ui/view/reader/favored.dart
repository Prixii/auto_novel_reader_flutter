import 'package:auto_novel_reader_flutter/bloc/cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/selector.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class FavoredView extends StatelessWidget {
  const FavoredView({super.key});

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
                  _buildNovelList(context),
                  _buildFavoredSelector(context),
                  _buildAddFavoredButton(),
                ],
              );
      },
    );
  }

  Widget _buildAddFavoredButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FloatingActionButton(
          onPressed: () async {
            // selectEpubFile(context);
          },
          tooltip: '添加收藏夹',
          child: const Icon(UniconsLine.folder_plus),
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
              final listWeb =
                  readFavoredCubit(context).state.favoredMap[NovelType.web];
              final favoredListWeb = (listWeb == null || listWeb.isEmpty)
                  ? <Favored>[Favored.createDefault()]
                  : listWeb;
              final listWenku =
                  readFavoredCubit(context).state.favoredMap[NovelType.wenku];
              final favoredListWenku = (listWenku == null || listWenku.isEmpty)
                  ? <Favored>[Favored.createDefault()]
                  : listWenku;

              return Stack(
                children: [
                  Visibility(
                    visible: currentType == NovelType.web,
                    child: Selector(
                        onTap: (_, index) => readFavoredCubit(context)
                            .setFavored(favored: favoredListWeb[index]),
                        tabs: favoredListWeb.map((e) => e.title).toList()),
                  ),
                  Visibility(
                    visible: currentType == NovelType.wenku,
                    child: Selector(
                        onTap: (_, index) => readFavoredCubit(context)
                            .setFavored(favored: favoredListWenku[index]),
                        tabs: favoredListWenku.map((e) => e.title).toList()),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNovelList(BuildContext context) {
    return BlocSelector<FavoredCubit, FavoredState, (List, NovelType)>(
      selector: (state) {
        final type = state.currentType;
        final favored = state.currentFavored ?? Favored.createDefault();
        if (type == NovelType.web) {
          final list =
              state.favoredWebNovelsMap[favored.id] ?? <WebNovelOutline>[];
          return (list, type);
        }
        if (type == NovelType.wenku) {
          final list =
              state.favoredWenkuNovelsMap[favored.id] ?? <WenkuNovelOutline>[];
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
              child:
                  WebNovelList(webNovels: listData.$1 as List<WebNovelOutline>),
            );
          case NovelType.wenku:
            return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 48.0, horizontal: 8),
                child: WenkuNovelList(
                    wenkuNovels: listData.$1 as List<WenkuNovelOutline>));
          default:
            throw Exception('invalid novel type');
        }
      },
    );
  }
}
