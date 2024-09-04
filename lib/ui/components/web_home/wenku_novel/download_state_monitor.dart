import 'package:auto_novel_reader_flutter/bloc/download_cubit/download_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class DownloadStateMonitor extends StatelessWidget {
  const DownloadStateMonitor({
    super.key,
    required this.filename,
    required this.onPressed,
  });

  final String filename;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: BlocSelector<DownloadCubit, DownloadState, DownloadType>(
          selector: (state) {
        return readDownloadCubit(context).getDownloadType(filename);
      }, builder: (context, downloadType) {
        switch (downloadType) {
          case DownloadType.downloading:
            return _buildDownloadProgress(filename);
          case DownloadType.none:
          case DownloadType.failed:
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: styleManager.colorScheme.secondaryContainer,
              ),
              onPressed: () => onPressed(),
              child: Icon(
                UniconsLine.file_download,
                color: styleManager.colorScheme.onSecondaryContainer,
              ),
            );
          case DownloadType.parsing:
            return LineButton(
              text: '解析中',
              onPressed: () => {},
            );
          case DownloadType.downloaded:
            return LineButton(
              text: '阅读',
              onPressed: () => {},
            );
        }
      }),
    );
  }

  Widget _buildDownloadProgress(String filename) {
    return BlocSelector<DownloadCubit, DownloadState, double>(
      selector: (state) {
        return state.progressMap[filename] ?? 0.0;
      },
      builder: (context, state) {
        return Center(
          child: Text(
            '${(state * 100).toStringAsFixed(2)}%',
          ),
        );
      },
    );
  }
}
