import 'package:auto_novel_reader_flutter/ui/components/reader/epub_chapter_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/epub_webview.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({super.key});

  @override
  State<EpubReaderView> createState() => _EpubReaderViewState();
}

class _EpubReaderViewState extends State<EpubReaderView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = readEpubViewerBloc(context).state.epubManageData?.name.trim();
    return Scaffold(
        appBar: AppBar(
          title: Text(title ?? ''),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shadowColor: Theme.of(context).appBarTheme.shadowColor,
        ),

        // Show table of contents
        drawer: const Drawer(
          child: EpubChapterList(),
        ),
        // Show epub document
        body: const EpubWebview());
  }
}
