import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RankNovelList extends StatelessWidget {
  const RankNovelList({
    super.key,
    required this.rankCategory,
  });

  final RankCategory rankCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48, left: 8, right: 8),
        child:
            BlocSelector<NovelRankBloc, NovelRankState, List<WebNovelOutline>>(
          selector: (state) {
            return state.novels[rankCategory] ?? [];
          },
          builder: (context, webNovels) {
            return Column(
              children: [
                WebNovelList(
                  webNovels: webNovels,
                  rankMode: true,
                  listMode: true,
                ),
                BlocSelector<NovelRankBloc, NovelRankState, bool>(
                  selector: (state) {
                    return state.searchingStatus[rankCategory] ?? false;
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
            );
          },
        ));
  }
}
