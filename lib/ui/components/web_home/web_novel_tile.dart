import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:auto_novel_reader_flutter/ui/view/web_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class WebNovelTile extends StatelessWidget {
  const WebNovelTile({super.key, required this.webNovel});

  final WebNovel webNovel;

  @override
  Widget build(BuildContext context) {
    return webNovel.map(
      webNovelChapter: (novel) => const SizedBox.shrink(),
      webNovelDto: (novel) => const SizedBox.shrink(),
      webNovelOutline: (novel) => _buildForWebOutline(novel, context),
      webNovelToc: (novel) => const SizedBox.shrink(),
    );
  }

  Widget _buildForWebOutline(WebNovelOutline webOutline, BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _toDetail(context, webOutline),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(webOutline.titleJp,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styleManager.primaryColorTitleSmall),
              Text(
                webOutline.titleZh ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Expanded(child: Container()),
              _buildFooter(webOutline, context),
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
    final lastReadChapter = readWebCacheCubit(context)
        .state
        .lastReadChapterMap[webOutline.providerId + webOutline.novelId];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (lastReadChapter == null)
            ? Text(
                '没有阅读记录',
                style: styleManager.tipText,
              )
            : Text(
                '最后阅读: 第$lastReadChapter章',
                style: styleManager.tipText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        Row(
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
        ),
      ],
    );
  }
}
