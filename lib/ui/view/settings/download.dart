import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme.shadow,
        backgroundColor: styleManager.colorScheme.secondaryContainer,
        title: const Text('下载管理'),
      ),
      body: const Center(child: Text('下载中')),
    );
  }
}
