import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChapterList extends StatelessWidget {
  const ChapterList({super.key});

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
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          _buildListBody(),
        ],
      ),
    );
  }

  Widget _buildListBody() {
    return BlocSelector<EpubViewerBloc, EpubViewerState,
        Map<String, List<String>>>(
      selector: (state) {
        return state.chapterResourceMap;
      },
      builder: (context, chapterResourceMap) {
        final entries = chapterResourceMap.entries.toList();
        return ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final chapterEntry = entries[index];
            return ChapterListTile(
              title:
                  chapterEntry.key == '' ? '章节${index + 1}' : chapterEntry.key,
              index: index,
            );
          },
          itemCount: entries.length,
        );
      },
    );
  }
}

class ChapterListTile extends StatelessWidget {
  const ChapterListTile({super.key, required this.title, required this.index});

  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EpubViewerBloc, EpubViewerState, int>(
      selector: (state) {
        return state.currentChapterIndex;
      },
      builder: (context, currentIndex) {
        final isCurrent = (currentIndex == index);
        final colorScheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: () {
            readEpubViewerBloc(context)
                .add(EpubViewerEvent.switchChapter(index, 0, canPop: false));
            Navigator.pop(context);
          },
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0)),
              color:
                  isCurrent ? colorScheme.primaryContainer : Colors.transparent,
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isCurrent ? colorScheme.primary : Colors.black,
                      ),
                ),
                _buildActiveBar(isCurrent, colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveBar(bool isCurrent, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: isCurrent ? colorScheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
