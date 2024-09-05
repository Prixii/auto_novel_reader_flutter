import 'package:auto_novel_reader_flutter/bloc/download_cubit/download_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

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
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          final taskEntries = state.taskStatus.entries.toList();
          return ListView.builder(
            itemBuilder: (_, index) {
              final filename = taskEntries[index].key;
              if (state.taskStatus[filename] == null) {
                return const SizedBox.shrink();
              }
              return DownloadItem(
                title: filename,
                progress: state.taskProgress[filename],
                downloadStatus: state.taskStatus[filename]!,
                extraInfo: state.taskExtraInfo[filename],
              );
            },
            itemCount: taskEntries.length,
          );
        },
      ),
    );
  }
}

class DownloadItem extends StatelessWidget {
  const DownloadItem(
      {super.key,
      this.progress,
      required this.downloadStatus,
      this.extraInfo,
      required this.title});

  final double? progress;
  final DownloadStatus downloadStatus;
  final String? extraInfo;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: _getColor(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styleManager.primaryColorTitleSmall,
              ),
            ),
            SizedBox(
              width: 100,
              child: _buildTrailingButton(context),
            )
          ]),
          if (extraInfo != null) Text(extraInfo!, style: styleManager.tipText),
        ],
      ),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      GestureDetector(
          onTap: () => readDownloadCubit(context).removeTask(title),
          child: const Icon(UniconsLine.trash_alt)),
      _getStatus(),
    ]);
  }

  Color _getColor() {
    switch (downloadStatus) {
      case DownloadStatus.failed:
        return styleManager.colorScheme.errorContainer;
      case DownloadStatus.succeed:
        return styleManager.colorScheme.secondaryContainer;
      default:
        return styleManager.colorScheme.tertiaryContainer;
    }
  }

  Widget _getStatus() {
    switch (downloadStatus) {
      case DownloadStatus.failed:
        return const Icon(UniconsLine.exclamation_circle);
      case DownloadStatus.succeed:
        return const Icon(UniconsLine.check);
      default:
        return Text(downloadStatus.name);
    }
  }
}
