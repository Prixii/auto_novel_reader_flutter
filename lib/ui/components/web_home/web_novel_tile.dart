import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:flutter/material.dart';

class WebNovelTile extends StatelessWidget {
  const WebNovelTile({super.key, required this.webNovel});

  final WebNovel webNovel;

  @override
  Widget build(BuildContext context) {
    return webNovel.map(
      webNovelChapter: (novel) => const SizedBox.shrink(),
      webNovelDto: (novel) => const SizedBox.shrink(),
      webNovelOutline: (novel) => _buildForWebOutline(novel),
      webNovelToc: (novel) => const SizedBox.shrink(),
    );
  }

  Widget _buildForWebOutline(WebNovelOutline webOutline) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(webOutline.titleJp,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styleManager.primaryColorTitle),
            Text(
              webOutline.titleZh ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(child: Container()),
            _buildFooter(webOutline),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(WebNovelOutline webOutline) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InfoBadge(
          webOutline.type,
          padding: const EdgeInsets.all(2),
        ),
        Text(
          '总计 ${webOutline.total} ',
          style: styleManager.tipText,
        ),
      ],
    );
  }
}
