import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:flutter/material.dart';

const _chapterTileHeight = 58.0;

class ChapterList extends StatelessWidget {
  const ChapterList({super.key, required this.tocList});

  final List<WebNovelToc> tocList;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 48.0, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '章节',
            style: styleManager.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          Expanded(child: _buildListBody()),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  Widget _buildListBody() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      prototypeItem: const SizedBox(
        height: _chapterTileHeight,
      ),
      itemBuilder: (context, index) {
        return ChapterListTile(
          titleJp: tocList[index].titleJp,
          titleZh: tocList[index].titleZh,
          index: index,
        );
      },
      itemCount: tocList.length,
    );
  }
}

class ChapterListTile extends StatelessWidget {
  const ChapterListTile(
      {super.key, required this.titleJp, this.titleZh, required this.index});

  final String titleJp;
  final String? titleZh;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
      ),
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: _chapterTileHeight,
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titleJp,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: styleManager.primaryColorTitleSmall),
                  Text(
                    titleZh ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
            Text(
              '${index + 1}',
              style: styleManager.textTheme.titleLarge?.copyWith(
                color: Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
