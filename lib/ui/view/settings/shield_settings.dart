import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:flutter/material.dart';

/// 当前 API 并不支持该功能
class ShieldSettings extends StatelessWidget {
  const ShieldSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme.shadow,
        backgroundColor: styleManager.colorScheme.secondaryContainer,
        title: const Text('屏蔽设置'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
    );
  }
}
