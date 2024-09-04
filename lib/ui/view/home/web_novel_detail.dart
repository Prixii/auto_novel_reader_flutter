import 'package:auto_novel_reader_flutter/bloc/web_cache/web_cache_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_novel_reader.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/chapter_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/flow_tag.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/introduction_card.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unicons/unicons.dart';

class WebNovelDetailContainer extends StatelessWidget {
  const WebNovelDetailContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WebHomeBloc, WebHomeState, WebNovelDto?>(
        selector: (state) {
      return state.webNovelDtoMap[
          '${state.currentNovelProviderId}${state.currentNovelId}'];
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
          drawer: Drawer(
            child: ChapterList(
              tocList: novelDto?.toc ?? [],
              novelKey: novelKey,
            ),
          ),
          body: WebNovelDetail(
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

class WebNovelDetail extends StatelessWidget {
  const WebNovelDetail(
      {super.key, required this.novelDto, required this.novelKey});

  final WebNovelDto? novelDto;
  final String novelKey;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (Scaffold.of(context).isDrawerOpen) return;
        readWebHomeBloc(context).add(const WebHomeEvent.leaveDetail());
      },
      child: (novelDto == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildNovelDetail(novelDto!, context),
            ),
    );
  }

  Widget _buildNovelDetail(WebNovelDto novelDto, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildTitle(novelDto),
        const SizedBox(height: 8.0),
        FlowTag(attentions: novelDto.attentions, keywords: novelDto.keywords),
        const SizedBox(height: 8.0),
        _buildAuthorInfo(novelDto),
        _buildUpdateInfo(novelDto),
        const SizedBox(height: 8.0),
        _buildButtonGroup(context),
        const SizedBox(height: 8.0),
        ..._buildIntroduction(novelDto),
        const SizedBox(height: 8.0),
        Text('评论', style: styleManager.boldMediumTitle),
        const SizedBox(height: 64.0),
      ],
    );
  }

  Widget _buildAuthorInfo(WebNovelDto novelDto) {
    return Row(children: [
      Text('作者: ', style: styleManager.tipText),
      Text(_getAuthors(novelDto),
          style: styleManager.tipText?.copyWith(
            color: styleManager.colorScheme.primary,
          )),
    ]);
  }

  Widget _buildUpdateInfo(WebNovelDto novelDto) {
    return Row(
      children: [
        Text(novelDto.type, style: styleManager.tipText),
        Text(' / ', style: styleManager.tipText),
        Text('${parseLargeNumber(novelDto.totalCharacters ?? 0)} 字',
            style: styleManager.tipText),
        Text(' / ', style: styleManager.tipText),
        Text('${parseLargeNumber(novelDto.visited)} 浏览',
            style: styleManager.tipText),
        Expanded(child: Container()),
        Text(
            '最近更新 ${parseTimeStamp((novelDto.toc?.last.createAt ?? 0) * 1000)}',
            style: styleManager.tipText),
      ],
    );
  }

  List<Widget> _buildTitle(WebNovelDto novelDto) {
    return [
      Text(
        novelDto.titleJp,
        style: styleManager.primaryColorTitleLarge,
      ),
      Text(
        novelDto.titleZh ?? '',
        style: styleManager.greyTitleMedium,
      ),
    ];
  }

  List<Widget> _buildIntroduction(WebNovelDto novelDto) {
    return [
      Text(
        '简介',
        style: styleManager.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      IntroductionCard(
        content: novelDto.introductionZh ?? '',
        style: styleManager.textTheme.bodyMedium,
      ),
      IntroductionCard(
        content: novelDto.introductionJp,
        style: styleManager.tipText,
      ),
    ];
  }

  String _getAuthors(WebNovelDto novelDto) {
    final authors = novelDto.authors;
    if (authors.isEmpty) return '未知';
    var authorName = '';
    for (var author in authors) {
      if (authorName.isNotEmpty) {
        authorName += ' / ';
      }
      authorName += author.name;
    }
    return authorName;
  }

  Widget _buildButtonGroup(BuildContext context) {
    return Row(children: [
      Expanded(
        child: BlocSelector<WebCacheCubit, WebCacheState, String?>(
          selector: (state) {
            return readWebCacheCubit(context)
                .state
                .lastReadChapterMap[novelKey];
          },
          builder: (context, lastReadChapterId) {
            return LineButton(
              onPressed: () => _readNovel(context, lastReadChapterId),
              text: (lastReadChapterId == null) ? '开始阅读' : '继续阅读',
            );
          },
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
                    readWebHomeBloc(context)
                        .add(const WebHomeEvent.unFavorNovel(NovelType.web));
                  } else {
                    readWebHomeBloc(context).add(
                      const WebHomeEvent.favorNovel(NovelType.web),
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

  void _readNovel(BuildContext context, String? lastReadChapterId) {
    readWebHomeBloc(context).add(WebHomeEvent.readChapter(lastReadChapterId));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlainTextNovelReaderContainer(),
      ),
    );
  }
}