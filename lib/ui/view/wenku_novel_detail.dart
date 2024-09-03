import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/flow_tag.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/introduction_card.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicons/unicons.dart';

class WenkuNovelDetailContainer extends StatelessWidget {
  const WenkuNovelDetailContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, WenkuNovelDto?>(
        selector: (state) {
      return state.wenkuNovelDtoMap[state.currentNovelId];
    }, builder: (context, novelDto) {
      final state = readWebHomeBloc(context).state;
      final novelKey = '${state.currentNovelProviderId}${state.currentNovelId}';
      return Scaffold(
          appBar: AppBar(
            shadowColor: styleManager.colorScheme.shadow,
            backgroundColor: styleManager.colorScheme.secondaryContainer,
            title: const Text('小说详情'),
            actions: _buildActions,
          ),
          body: WenkuNovelDetail(
            novelDto: novelDto,
            novelKey: novelKey,
          ));
    });
  }

  List<Widget> get _buildActions {
    return [
      IconButton(
        onPressed: () {
          // TODO 编辑
          Fluttertoast.showToast(msg: '这个功能还没有做呢');
        },
        icon: const Icon(UniconsLine.edit),
      ),
      IconButton(
        onPressed: () {
          // TODO 复制链接到剪贴板
          Fluttertoast.showToast(msg: '这个功能还没有做呢');
        },
        icon: const Icon(UniconsLine.link),
      ),
    ];
  }
}

class WenkuNovelDetail extends StatelessWidget {
  const WenkuNovelDetail(
      {super.key, required this.novelDto, required this.novelKey});

  final WenkuNovelDto? novelDto;
  final String novelKey;

  @override
  Widget build(BuildContext context) {
    return (novelDto == null)
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildNovelDetail(novelDto!, context),
          );
  }

  Widget _buildNovelDetail(WenkuNovelDto novelDto, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCovers(_getCoverUrls(novelDto)),
        const SizedBox(height: 8.0),
        ..._buildTitle(novelDto),
        const SizedBox(height: 8.0),
        FlowTag(attentions: const [], keywords: novelDto.keywords),
        const SizedBox(height: 8.0),
        _buildAuthorsInfo(novelDto),
        _buildArtistsInfo(novelDto),
        _buildPublisherInfo(novelDto),
        _buildUpdateInfo(novelDto),
        const SizedBox(height: 8.0),
        _buildButtonGroup(context),
        const SizedBox(height: 8.0),
        ..._buildIntroduction(novelDto),
        const SizedBox(height: 8.0),
        Text(
          '评论',
          style: styleManager.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 64.0),
      ],
    );
  }

  Widget _buildCovers(List<String> urls) {
    return SizedBox(
      height: 328,
      child: PageView.builder(
        itemBuilder: (context, index) => CachedNetworkImage(
          imageUrl: urls[index],
          fit: BoxFit.fitHeight,
        ),
        itemCount: urls.length,
      ),
    );
  }

  List<String> _getCoverUrls(WenkuNovelDto novelDto) {
    var urls = <String>[];
    if (novelDto.cover != null) {
      urls.add(novelDto.cover!);
    }
    for (var volume in novelDto.volumes) {
      if (volume.cover != null) {
        urls.add(volume.cover!);
      }
    }
    return urls;
  }

  Widget _buildAuthorsInfo(WenkuNovelDto novelDto) {
    return Row(children: [
      Text('作者: ', style: styleManager.tipText),
      Text(_uniteMembers(novelDto.authors),
          style: styleManager.tipText?.copyWith(
            color: styleManager.colorScheme.primary,
          )),
    ]);
  }

  Widget _buildArtistsInfo(WenkuNovelDto novelDto) {
    return Row(children: [
      Text('插图: ', style: styleManager.tipText),
      Text(_uniteMembers(novelDto.artists),
          style: styleManager.tipText?.copyWith(
            color: styleManager.colorScheme.primary,
          )),
    ]);
  }

  Widget _buildPublisherInfo(WenkuNovelDto novelDto) {
    return Row(children: [
      Text('出版: ', style: styleManager.tipText),
      Text('${novelDto.publisher} ',
          style: styleManager.tipText?.copyWith(
            color: styleManager.colorScheme.primary,
          )),
      Text(novelDto.imprint ?? '',
          style: styleManager.tipText?.copyWith(
            color: styleManager.colorScheme.primary,
          )),
    ]);
  }

  Widget _buildUpdateInfo(WenkuNovelDto novelDto) {
    return Row(
      children: [
        Text(novelDto.level, style: styleManager.tipText),
        Text(' / ', style: styleManager.tipText),
        Text('共 ${novelDto.volumes.length} 卷', style: styleManager.tipText),
        Text(' / ', style: styleManager.tipText),
        Text('${parseLargeNumber(novelDto.visited)} 浏览',
            style: styleManager.tipText),
        Expanded(child: Container()),
        Text('最新出版 ${parseTimeStamp((novelDto.latestPublishAt ?? 0) * 1000)}',
            style: styleManager.tipText),
      ],
    );
  }

  List<Widget> _buildTitle(WenkuNovelDto novelDto) {
    return [
      Text(
        novelDto.title,
        style: styleManager.primaryColorTitleLarge,
      ),
      Text(
        novelDto.titleZh,
        style: styleManager.greyTitleMedium,
      ),
    ];
  }

  List<Widget> _buildIntroduction(WenkuNovelDto novelDto) {
    return [
      Text(
        '简介',
        style: styleManager.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      IntroductionCard(
        content: novelDto.introduction,
        style: styleManager.textTheme.bodyMedium,
      ),
    ];
  }

  String _uniteMembers(List<String> members) {
    var result = '';
    for (var item in members) {
      if (result.isNotEmpty) {
        result += ' / ';
      }
      result += item;
    }
    return result;
  }

  Widget _buildButtonGroup(BuildContext context) {
    return Row(children: [
      Expanded(
        child: LineButton(
          onPressed: () => _toDownload(context),
          text: '阅读',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: BlocSelector<WebHomeBloc, WebHomeState, bool>(
          selector: (state) {
            return state.favoredWebMap[novelKey] != null;
          },
          builder: (context, favored) {
            return LineButton(
                onPressed: () {
                  if (favored) {
                    readWenkuHomeBloc(context)
                        .add(const WenkuHomeEvent.unFavorNovel());
                  } else {
                    readWenkuHomeBloc(context).add(
                      const WenkuHomeEvent.favorNovel(),
                    );
                  }
                },
                onDisabledPressed: () => showWarnToast('请先登录'),
                enabled: readUserCubit(context).isSignIn,
                text: favored ? '已收藏' : '收藏');
          },
        ),
      )
    ]);
  }

  _toDownload(BuildContext context) {}
}
