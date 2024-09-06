import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EpubChapterList extends StatefulWidget {
  const EpubChapterList({super.key});

  @override
  State<EpubChapterList> createState() => _EpubChapterListState();
}

class _EpubChapterListState extends State<EpubChapterList> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex();
    });
  }

  void _scrollToIndex() {
    final state = readEpubViewerBloc(context).state;
    final index = state.currentChapterIndex;
    final itemCount = state.chapterResourceMap.length;
    if (index >= itemCount) return;
    _scrollController
        .jumpTo(_scrollController.position.maxScrollExtent / itemCount * index);
  }

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
          Expanded(child: _buildListBody()),
          const SizedBox(height: 12.0),
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
          controller: _scrollController,
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          prototypeItem: const EpubChapterListTile(title: '章节', index: 0),
          itemBuilder: (context, index) {
            final chapterEntry = entries[index];
            return EpubChapterListTile(
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

class EpubChapterListTile extends StatelessWidget {
  const EpubChapterListTile(
      {super.key, required this.title, required this.index});

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
                        color: isCurrent
                            ? colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
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
