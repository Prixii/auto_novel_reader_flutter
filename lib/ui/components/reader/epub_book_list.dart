import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_book_cover.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
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
                key: Key(epubList[index].uid),
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
    localFileManager
        .getCover(widget.epubManageData.uid)
        .then((coverFile) async {
      if (coverFile != null &&
          coverFile.existsSync() &&
          (await coverFile.length() > 0)) {
        cover = coverFile;
      }
      if (mounted) {
        setState(() {
          loadingCover = false;
        });
      }
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  height: double.infinity,
                  width: 80,
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
        const SizedBox(height: 4.0),
        Text(
          widget.epubManageData.name.trim(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
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
        title: widget.epubManageData.name.trim(),
      );
    }
    return Image.file(
      cover!,
      fit: BoxFit.fitHeight,
      key: Key(
        widget.epubManageData.uid,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildReadProgressInfo(),
        PopupMenuButton(
          icon: const Icon(UniconsLine.ellipsis_v),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('编辑信息'),
              onTap: () async {
                _showInfoEditor(context);
              },
            ),
            PopupMenuItem(
              child: Text(
                '删除',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                _askToDelete(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadProgressInfo() {
    final progress =
        '${((widget.epubManageData.progress) * 100).toStringAsFixed(2)} %';
    final chapterTitle = '第${(widget.epubManageData.chapter) + 1}章';
    return Text(
      '$chapterTitle ($progress)',
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _askToDelete(BuildContext widgetContext) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确定删除书籍?'),
          content: const Text('阅读进度将会丢失'),
          actions: [
            TextButton(
              child: const Text('算了吧'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '删！',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
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

  void _showInfoEditor(BuildContext widgetContext) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: screenSize.width,
        maxHeight: screenSize.height * 0.8,
      ),
      enableDrag: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              SizedBox(
                height: 198,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _buildCover(),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                widget.epubManageData.name.trim(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ..._buildEditOption(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildEditOption() => [
        LineButton(
          text: '设置封面（从书籍图片中选择）',
          onPressed: () {
            Navigator.of(context).pop();
            // TODO
          },
        ),
        LineButton(
          text: '设置封面（从内部存储）',
          onPressed: () {
            Navigator.of(context).pop();
            // TODO
          },
        ),
        LineButton(
          text: '修改标题',
          onPressed: () {
            Navigator.of(context).pop();
            // TODO
          },
        ),
      ];
}
