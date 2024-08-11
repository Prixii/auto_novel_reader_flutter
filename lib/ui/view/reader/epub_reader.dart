import 'package:auto_novel_reader_flutter/ui/components/reader/epub_webview.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text(epubUtil.title.trimLeft()),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shadowColor: Theme.of(context).appBarTheme.shadowColor,
        ),

        // Show table of contents
        drawer: Drawer(),
        // Show epub document
        body: SingleChildScrollView(
          child: (epubUtil.currentPath == null)
              ? const Text('no data!')
              : EpubWebview(
                  htmlFilePath: '${epubUtil.currentPath}/text00011.html'),
        ));
  }
}
