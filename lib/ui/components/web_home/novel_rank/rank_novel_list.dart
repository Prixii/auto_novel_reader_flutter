import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
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
    return BlocSelector<NovelRankBloc, NovelRankState, List<WebNovelOutline>>(
      selector: (state) {
        return state.novels[rankCategory] ?? [];
      },
      builder: (context, webNovels) {
        return BlocSelector<NovelRankBloc, NovelRankState, LoadingStatus?>(
          selector: (state) {
            return state.loadingStatus[rankCategory];
          },
          builder: (context, loadingStatus) {
            return RefreshList(
                loadingStatus: loadingStatus,
                onRetry: () async {
                  readNovelRankBloc(context)
                      .add(NovelRankEvent.searchRankNovel(rankCategory));
                },
                child: WebNovelList(
                  webNovels: webNovels,
                  rankMode: true,
                  listMode: true,
                ));
          },
        );
      },
    );
  }
}
