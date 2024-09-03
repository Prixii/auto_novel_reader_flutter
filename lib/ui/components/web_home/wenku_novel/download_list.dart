import 'package:auto_novel_reader_flutter/bloc/download_cubit/download_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/path_manager.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/file_downloader.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/view/download.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class DownloadList extends StatelessWidget {
  const DownloadList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shadowColor: styleManager.colorScheme.shadow,
          backgroundColor: styleManager.colorScheme.secondaryContainer,
          title: const Text('小说详情'),
          actions: _buildActions(context),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('目录', style: styleManager.boldMediumTitle),
              const SizedBox(height: 8),
              _buildMenu(),
              const SizedBox(height: 8),
              Text('中文', style: styleManager.boldMediumTitle),
              const SizedBox(height: 8),
              _buildZhMenu(),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }

  Widget _buildMenu() {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, List<VolumeJpDto>>(
      selector: (state) {
        return state.currentWenkuNovelDto?.volumeJp ?? [];
      },
      builder: (context, jpVolumes) {
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              JpVolumeListTile(dto: jpVolumes[index]),
          itemCount: jpVolumes.length,
        );
      },
    );
  }

  Widget _buildZhMenu() {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, List<String>>(
      selector: (state) {
        return state.currentWenkuNovelDto?.volumeZh ?? [];
      },
      builder: (context, zhVolumes) {
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              ZhVolumeListTile(title: zhVolumes[index]),
          itemCount: zhVolumes.length,
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => _toDownloadPage(context),
          icon: const Icon(
            UniconsLine.download_alt,
          ),
        ),
      ];

  void _toDownloadPage(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DownloadPage(),
        ),
      );
}

class JpVolumeListTile extends StatelessWidget {
  const JpVolumeListTile({super.key, required this.dto});

  final VolumeJpDto dto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Text(
                dto.volumeId,
                style: styleManager.primaryColorTitleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getTranslationCount,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        _buildTrail(context),
      ],
    );
  }

  Widget _buildTrail(BuildContext context) {
    final state = readWenkuHomeBloc(context).state;
    final (fileName, url) = jpDownloadUrlGenerator(
        readWenkuHomeBloc(context).state.currentNovelId, dto.volumeId,
        mode: state.language,
        translationsMode: state.translationMode,
        translations: state.translationOrder);
    return SizedBox(
      width: 78,
      child: BlocSelector<DownloadCubit, DownloadState, DownloadType>(
        selector: (state) {
          return readDownloadCubit(context).getDownloadType(fileName);
        },
        builder: (context, downloadType) {
          switch (downloadType) {
            case DownloadType.downloading:
              return BlocSelector<DownloadCubit, DownloadState, double>(
                selector: (state) {
                  return state.progressMap[dto.volumeId] ?? 0.0;
                },
                builder: (context, state) {
                  return Text(
                    '${(state * 100).toStringAsFixed(2)}%',
                  );
                },
              );
            case DownloadType.none:
            case DownloadType.failed:
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: styleManager.colorScheme.secondaryContainer,
                ),
                onPressed: () {
                  _downloadJpEpub(context, fileName, url);
                },
                child: Icon(
                  UniconsLine.file_download,
                  color: styleManager.colorScheme.onSecondaryContainer,
                ),
              );
            case DownloadType.downloaded:
              return LineButton(
                text: '阅读',
                onPressed: () => {},
              );
          }
        },
      ),
    );
  }

  void _downloadJpEpub(BuildContext context, String fileName, String url) {
    talker.debug('fileName: $fileName, url: $url');
    readDownloadCubit(context)
        .createDownloadTask(url, pathManager.epubDownloadPath, fileName);
  }

  String get _getTranslationCount =>
      '总计 ${dto.total} / 百度 ${dto.baidu} / 有道 ${dto.youdao} /\n GPT ${dto.gpt} / Sakura ${dto.sakura}';
}

class ZhVolumeListTile extends StatelessWidget {
  const ZhVolumeListTile({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Text(
                title,
                style: styleManager.primaryColorTitleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        _buildTrail(context),
      ],
    );
  }

  Widget _buildTrail(BuildContext context) {
    return SizedBox(
      width: 78,
      child: BlocSelector<DownloadCubit, DownloadState, DownloadType>(
        selector: (state) {
          return readDownloadCubit(context).getDownloadType(title);
        },
        builder: (context, downloadType) {
          switch (downloadType) {
            case DownloadType.downloading:
              return BlocSelector<DownloadCubit, DownloadState, double>(
                selector: (state) {
                  return state.progressMap[title] ?? 0.0;
                },
                builder: (context, state) {
                  return Text(
                    '${(state * 100).toStringAsFixed(2)}%',
                  );
                },
              );
            case DownloadType.none:
            case DownloadType.failed:
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: styleManager.colorScheme.secondaryContainer,
                ),
                onPressed: () => _downloadZhEpub(
                    context,
                    zhDownloadUrlGenerator(
                      readWenkuHomeBloc(context).state.currentNovelId,
                      title,
                    ),
                    title),
                child: Icon(
                  UniconsLine.file_download,
                  color: styleManager.colorScheme.onSecondaryContainer,
                ),
              );
            case DownloadType.downloaded:
              return LineButton(
                text: '阅读',
                onPressed: () => {},
              );
          }
        },
      ),
    );
  }

  void _downloadZhEpub(BuildContext context, String url, String title) {
    readDownloadCubit(context)
        .createDownloadTask(url, pathManager.epubDownloadPath, title);
  }
}
