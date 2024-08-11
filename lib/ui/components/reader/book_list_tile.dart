import 'dart:io';

import 'package:auto_novel_reader_flutter/ui/view/reader/epub_reader.dart';
import 'package:auto_novel_reader_flutter/manager/local_file_manager.dart';
import 'package:flutter/material.dart';

class BookListTile extends StatelessWidget {
  const BookListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final path = localFileManager.getEpubFilePath('test');
        if (path == null) return;
        final epubFile = File(path);
        if (!epubFile.existsSync()) {
          throw Exception('epub file not found');
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EpubReaderView(epubFile: epubFile)));
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
