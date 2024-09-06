import 'package:auto_novel_reader_flutter/bloc/web_cache/web_cache_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_novel_reader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

const _chapterTileHeight = 58.0;

class ChapterList extends StatefulWidget {
  const ChapterList(
      {super.key,
      required this.novelKey,
      required this.tocList,
      this.readMode = false});

  final List<WebNovelToc> tocList;
  final bool readMode;
  final String novelKey;

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locateToLastIndex();
    });
  }

  void _locateToLastIndex() {
    final currentChapterId =
        readWebCacheCubit(context).state.lastReadChapterMap[widget.novelKey];
    if (currentChapterId == null) return;
    final currentIndex =
        widget.tocList.indexWhere((toc) => toc.chapterId == currentChapterId);
    _scrollToIndex(currentIndex);
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * _chapterTileHeight,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCirc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 48.0, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '章节',
                  style: styleManager.textTheme.headlineSmall,
                ),
              ),
              IconButton(
                  onPressed: () => _locateToLastIndex(),
                  icon: const Icon(UniconsLine.location_point)),
              IconButton(
                  onPressed: () => _scrollToIndex(0),
                  icon: const Icon(UniconsLine.arrow_up)),
            ],
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
        return state.lastReadChapterMap[widget.novelKey];
      },
      builder: (context, currentChapterId) {
        return ListView.builder(
          padding: const EdgeInsets.all(0),
          controller: _scrollController,
          shrinkWrap: true,
          prototypeItem: const SizedBox(
            height: _chapterTileHeight,
          ),
          itemBuilder: (context, index) {
            return ChapterListTile(
              titleJp: widget.tocList[index].titleJp,
              titleZh: widget.tocList[index].titleZh,
              index: index,
              chapterId: widget.tocList[index].chapterId,
              readMode: widget.readMode,
              currentChapterId: currentChapterId,
            );
          },
          itemCount: widget.tocList.length,
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
      required this.chapterId,
      this.readMode = false});

  final String? currentChapterId;
  final String titleJp;
  final String? titleZh;
  final String? chapterId;
  final bool readMode;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isCurrent = (currentChapterId == chapterId);
    return InkWell(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
      ),
      onTap: () {
        if (chapterId == null) return;
        context.read<WebHomeBloc>().add(WebHomeEvent.readChapter(chapterId!));
        Navigator.pop(context);
        if (!readMode) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlainTextNovelReaderContainer(),
            ),
          );
        }
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
              '$index',
              style: styleManager.textTheme.titleLarge?.copyWith(
                color: isCurrent
                    ? styleManager.colorScheme.primary
                    : MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.grey
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
