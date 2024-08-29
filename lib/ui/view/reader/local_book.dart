import 'dart:io';

import 'package:auto_novel_reader_flutter/bloc/local_file/local_file_cubit.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/epub_book_list.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalBookView extends StatelessWidget {
  const LocalBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BlocSelector<LocalFileCubit, LocalFileState, List<EpubManageData>>(
        selector: (state) {
          return state.epubManageDataList;
        },
        builder: (context, epubList) {
          if (epubList.isEmpty) {
            return const Center(child: Text('没有书籍哦~'));
          }
          return EpubBookList(
            epubList: epubList,
          );
        },
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
            onPressed: () async {
              selectEpubFile(context);
            },
            tooltip: '添加书籍',
            child: const Icon(Icons.add),
          ),
        ),
      )
    ]);
  }

  void selectEpubFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result == null) return;
    for (var file in result.files) {
      final path = file.path;
      if (path == null) return;
      final epubFile = File(path);
      if (!epubFile.existsSync()) {
        throw Exception('epub file not found');
      }
      if (context.mounted) {
        await readLocalFileCubit(context)
            .selectFile(file: epubFile, context: context);
      }
    }
    // final path = result.files.single.path;
    // if (path == null) return;
    // final epubFile = File(path);
    // if (!epubFile.existsSync()) {
    //   throw Exception('epub file not found');
    // }
    // if (context.mounted) {
    //   readLocalFileCubit(context).selectFile(file: epubFile, context: context);
    // }
  }
}
