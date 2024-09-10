import 'dart:io';

import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late File currentLogFile;
  List<String> logs = [];
  List<String> logPathList = [];
  int currentLogFileIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!errorLogger.logFile.existsSync()) return;
    currentLogFile = errorLogger.logFile;
    List<String> logData = _readLog();
    logPathList = pathManager.getLogPathList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        logs = logData;
        currentLogFileIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme(context).shadow,
        backgroundColor: styleManager.colorScheme(context).secondaryContainer,
        title: const Text('日志管理'),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              LogCard(log: logs[index], index: index),
          itemCount: logs.length,
        ),
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemBuilder: (context, index) {
            final path = logPathList[index];
            return ListTile(
              selected: currentLogFileIndex == index,
              selectedColor:
                  styleManager.colorScheme(context).onSecondaryContainer,
              selectedTileColor:
                  styleManager.colorScheme(context).secondaryContainer,
              title: Text(path.split('/').last),
              onTap: () {
                _loadLogByPathIndex(index);
                Navigator.pop(context);
              },
            );
          },
          itemCount: logPathList.length,
        ),
      ),
    );
  }

  Future<void> _loadLogByPathIndex(int index) async {
    final logPath = logPathList[index];
    currentLogFile = File(logPath);
    setState(() {
      logs = [];
      currentLogFileIndex = index;
    });
    final logData = _readLog();
    setState(() {
      logs = logData;
    });
  }

  List<String> _readLog() {
    final rawRogData = currentLogFile.readAsLinesSync();
    var logData = <String>[];
    var logItem = '';
    for (var element in rawRogData) {
      logItem = '$logItem$element\n';
      if (element == errorLogger.logDivider) {
        logData.insert(0, logItem);
        logItem = '';
      }
    }
    return logData;
  }
}

class LogCard extends StatefulWidget {
  const LogCard({
    super.key,
    required this.log,
    required this.index,
  });

  final String log;
  final int index;

  @override
  State<LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<LogCard> {
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: styleManager.colorScheme(context).errorContainer,
        ),
        child: InkWell(
            onTap: () => expand(),
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: widget.log))
                    .then((value) {
                  showSucceedToast('错误日志已复制到剪切板');
                }),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.log,
                maxLines: expanded ? null : 4,
                overflow: expanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  color: styleManager.colorScheme(context).onErrorContainer,
                ),
              ),
            )),
      ),
    );
  }

  void expand() {
    setState(() {
      expanded = !expanded;
    });
  }
}
