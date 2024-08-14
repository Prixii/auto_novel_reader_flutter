import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_book_cover.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EpubBookList extends StatelessWidget {
  const EpubBookList({
    super.key,
    required this.epubList,
  });

  final List<EpubManageData> epubList;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: BookListTile(
                epubManageData: epubList[index],
                key: Key(epubList[index].uid ?? '-'),
              ),
            ),
          ),
        ),
        itemCount: epubList.length,
      ),
    );
  }
}

class BookListTile extends StatefulWidget {
  const BookListTile({
    super.key,
    required this.epubManageData,
  });

  final EpubManageData epubManageData;

  @override
  State<BookListTile> createState() => _BookListTileState();
}

class _BookListTileState extends State<BookListTile> {
  var loadingCover = true;
  File? cover;

  @override
  void initState() {
    super.initState();
    localFileManager.getCover(widget.epubManageData.uid ?? '-').then((value) {
      setState(() {
        loadingCover = false;
        cover = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: InkWell(
        onTap: () {
          readEpubViewerBloc(context)
              .add(EpubViewerEvent.open(widget.epubManageData, context));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 128,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _buildCover(),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildBookInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.epubManageData.name?.trim() ?? '',
        ),
        Expanded(child: Container()),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildCover() {
    if (loadingCover) {
      return const CircularProgressIndicator();
    }
    if (cover == null) {
      return PlainTextBookCover(
        title: widget.epubManageData.name?.trim(),
      );
    }
    return Image.file(
      cover!,
      fit: BoxFit.cover,
      key: Key(
        widget.epubManageData.uid ?? widget.epubManageData.hashCode.toString(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildReadProgressInfo(),
        IconButton(
          icon: const Icon(UniconsLine.trash_alt),
          onPressed: () async {
            _askToDelete(context, context);
          },
          color: Theme.of(context).colorScheme.error,
        )
      ],
    );
  }

  Widget _buildReadProgressInfo() {
    final progress =
        '${((widget.epubManageData.progress ?? 0) * 100).toStringAsFixed(2)} %';
    final chapterTitle = '第${(widget.epubManageData.chapter ?? 0) + 1}章';
    return Text(
      '$chapterTitle ($progress)',
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _askToDelete(
      BuildContext context, BuildContext widgetContext) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('您确定要删除此书籍吗?'),
          content: const Text('阅读进度将会丢失'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                if (widgetContext.mounted) {
                  readLocalFileCubit(widgetContext)
                      .deleteEpubBook(widget.epubManageData);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
