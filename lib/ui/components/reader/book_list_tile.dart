import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class BookListTile extends StatelessWidget {
  const BookListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final path = localFileManager.getEpubFilePath('test0');
        if (path == null) return;
        final epubFile = File(path);
        if (!epubFile.existsSync()) throw Exception('epub file not found');

        readEpubViewerBloc(context)
            .add(EpubViewerEvent.open(epubFile, context));
      },
      child: Row(
        children: [
          FlutterLogo(),
          Text('BookListTile'),
        ],
      ),
    );
  }
}
