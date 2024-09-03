import 'package:auto_novel_reader_flutter/bloc/web_cache/web_cache_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _chapterTileHeight = 58.0;

class ChapterList extends StatelessWidget {
  const ChapterList(
      {super.key,
      required this.novelKey,
      required this.tocList,
      this.readMode = false});

  final List<WebNovelToc> tocList;
  final bool readMode;
  final String novelKey;
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
    return BlocSelector<WebCacheCubit, WebCacheState, String?>(
      selector: (state) {
        return state.lastReadChapterMap[novelKey];
      },
      builder: (context, currentChapterId) {
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
              index: tocList[index].chapterId,
              readMode: readMode,
              currentChapterId: currentChapterId,
            );
          },
          itemCount: tocList.length,
        );
      },
    );
  }
}

class ChapterListTile extends StatelessWidget {
  const ChapterListTile(
      {super.key,
      required this.titleJp,
      this.titleZh,
      this.currentChapterId,
      required this.index,
      this.readMode = false});

  final String? currentChapterId;
  final String titleJp;
  final String? titleZh;
  final String? index;
  final bool readMode;

  @override
  Widget build(BuildContext context) {
    final isCurrent = (readMode && (currentChapterId == index));
    return InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
      ),
      onTap: () {
        if (!readMode) return;
        if (index == null) return;
        context.read<WebHomeBloc>().add(WebHomeEvent.readChapter(index!));
        Navigator.pop(context);
      },
      child: Container(
        height: _chapterTileHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
          color: isCurrent
              ? styleManager.colorScheme.primaryContainer
              : Colors.transparent,
        ),
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
                      style: styleManager.primaryColorTitleSmall?.copyWith(
                        color: isCurrent
                            ? styleManager.colorScheme.onPrimaryContainer
                            : styleManager.colorScheme.primary,
                      )),
                  Text(titleZh ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: styleManager.titleSmall?.copyWith(
                        color: isCurrent
                            ? styleManager.colorScheme.onSecondaryContainer
                            : Colors.black54,
                      ))
                ],
              ),
            ),
            Text(
              index ?? '',
              style: styleManager.textTheme.titleLarge?.copyWith(
                color: isCurrent
                    ? styleManager.colorScheme.primary
                    : Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
