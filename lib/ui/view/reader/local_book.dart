import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/book_list_tile.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/epub_reader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class LocalBookView extends StatelessWidget {
  const LocalBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BookListTile(),
      const Center(child: Text('LocalBookView')),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
            onPressed: () async {
              selectEpubFile(context);
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ),
      )
    ]);
  }

  void selectEpubFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    final epubFile = File(path);
    if (!epubFile.existsSync()) {
      throw Exception('epub file not found');
    }
    if (context.mounted) {
      readEpubViewerBloc(context).add(EpubViewerEvent.open(epubFile, context));
    }
  }
}
