import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/log_page.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme(context).shadow,
        backgroundColor: styleManager.colorScheme(context).secondaryContainer,
        title: const Text('数据管理'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconOption(
              icon: UniconsLine.brush_alt,
              text: '清空 Epub 缓存',
              tip: '所有的 epub 都需要重新下载和解析哦',
              onTap: () => {_cleanCache(context)},
            ),
            IconOption(
              icon: UniconsLine.brush_alt,
              text: '清理日志',
              onTap: () => errorLogger.cleanAllLogs(),
            ),
            IconOption(
              icon: UniconsLine.brush_alt,
              text: '清空下载任务记录',
              onTap: () => readDownloadCubit(context).clearAllTasks(),
            ),
            Divider(
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).dividerColor),
            IconOption(
                icon: UniconsLine.exclamation_triangle,
                text: '查看日志',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LogPage()))),
          ],
        ),
      ),
    );
  }

  void _cleanCache(BuildContext context) {
    readLocalFileCubit(context).cleanEpubManageData();
  }
}
