import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme.shadow,
        backgroundColor: styleManager.colorScheme.secondaryContainer,
        title: const Text('数据管理'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconOption(
              icon: UniconsLine.brush_alt,
              text: '清空解析缓存',
              tip: '清除所有 epub',
              onTap: () => _cleanCache(context),
            ),
          ],
        ),
      ),
    );
  }

  void _cleanCache(BuildContext context) {
    readLocalFileCubit(context).cleanEpubManageData();
  }
}
