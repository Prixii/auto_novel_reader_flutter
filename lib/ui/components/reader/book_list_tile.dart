import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

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
    localFileManager.getCover(widget.epubManageData.uid).then((value) {
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
          final epubUid = widget.epubManageData.uid;
          final path = localFileManager.getEpubFilePath(epubUid) ?? '';
          final epubFile = File(path);
          if (!epubFile.existsSync()) throw Exception('epub file not found');

          readEpubViewerBloc(context)
              .add(EpubViewerEvent.open(epubFile, context));
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 128,
          child: Row(
            children: [
              SizedBox(width: 80, child: _buildCover()),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.epubManageData.name.trim(),
                    ),
                    Expanded(child: Container()),
                    _buildReadProgressInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (loadingCover) {
      return const CircularProgressIndicator();
    }
    if (cover == null) {
      return const Text('no cover');
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          cover!,
          fit: BoxFit.cover,
        ));
  }

  Widget _buildReadProgressInfo() {
    return Text(
      '${widget.epubManageData.chapter} 章 ${widget.epubManageData.progress} %',
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.grey,
      ),
    );
  }
}
