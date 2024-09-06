import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/web_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class WebNovelList extends StatelessWidget {
  const WebNovelList({
    super.key,
    required this.webNovels,
    this.rankMode = false,
    this.childAspectRatio = 1.1,
    this.listMode = false,
  });

  final List<WebNovelOutline> webNovels;
  final bool rankMode;
  final double childAspectRatio;
  final bool listMode;

  @override
  Widget build(BuildContext context) {
    return listMode ? _buildList() : _buildGrid();
  }

  Widget _buildList() {
    return AnimationLimiter(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                AnimationConfiguration.staggeredList(
                  duration: const Duration(milliseconds: 375),
                  position: index,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: WebNovelTile(
                        novelOutline: webNovels[index],
                        rankMode: rankMode,
                        listMode: listMode,
                      ),
                    ),
                  ),
                ),
            itemCount: webNovels.length));
  }

  Widget _buildGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: childAspectRatio,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
          duration: const Duration(milliseconds: 375),
          position: index,
          columnCount: 2,
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: WebNovelTile(
                novelOutline: webNovels[index],
                rankMode: rankMode,
                listMode: listMode,
              ),
            ),
          ),
        ),
        itemCount: webNovels.length,
      ),
    );
  }
}

class WebNovelTile extends StatelessWidget {
  const WebNovelTile(
      {super.key,
      required this.novelOutline,
      this.rankMode = false,
      this.listMode = false});

  final WebNovelOutline novelOutline;
  final bool rankMode;
  final bool listMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _toDetail(context, novelOutline),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(novelOutline.titleJp,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styleManager.primaryColorTitleSmall),
              Text(
                novelOutline.titleZh ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              (rankMode || listMode)
                  ? const SizedBox.shrink()
                  : Expanded(child: Container()),
              _buildFooter(novelOutline, context),
            ],
          ),
        ),
      ),
    );
  }

  void _toDetail(BuildContext context, WebNovelOutline webOutline) {
    readWebHomeBloc(context).add(WebHomeEvent.toNovelDetail(
      webOutline.providerId,
      webOutline.novelId,
    ));
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const WebNovelDetailContainer()));
  }

  Widget _buildFooter(WebNovelOutline webOutline, BuildContext context) {
    // final lastReadChapter = readWebCacheCubit(context)
    // .state
    // .lastReadChapterMap[webOutline.providerId + webOutline.novelId];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO 现有 api 暂不支持阅读记录
        // (lastReadChapter == null)
        //     ? Text(
        //         '没有阅读记录',
        //         style: styleManager.tipText,
        //       )
        //     : Text(
        //         '最后阅读: 第$lastReadChapter章',
        //         style: styleManager.tipText,
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //       ),
        rankMode ? _buildRankInfo(webOutline) : _buildNormalInfo(webOutline),
      ],
    );
  }

  Row _buildNormalInfo(WebNovelOutline webOutline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '总计 ${webOutline.total} ',
          style: styleManager.tipText,
        ),
        InfoBadge(
          webOutline.type,
          padding: const EdgeInsets.all(2),
        ),
      ],
    );
  }

  Widget _buildRankInfo(WebNovelOutline webOutline) {
    return Text(webOutline.extra ?? '', style: styleManager.tipText);
  }
}
