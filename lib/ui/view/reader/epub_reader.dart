import 'dart:io';

import 'package:auto_novel_reader_flutter/controller/epub_controller.dart';
import 'package:flutter/material.dart';

class EpubReaderView extends StatefulWidget {
  const EpubReaderView({super.key, required this.epubFile});

  final File epubFile;

  @override
  State<EpubReaderView> createState() => _EpubReaderViewState();
}

class _EpubReaderViewState extends State<EpubReaderView> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    _epubController = EpubController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),

        // Show table of contents
        drawer: Drawer(),
        // Show epub document
        body: Center());
  }
}
