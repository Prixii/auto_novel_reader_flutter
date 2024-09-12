import 'package:auto_novel_reader_flutter/bloc/comment/comment_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_cache/web_cache_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/ui/components/favored/favored_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_novel_reader.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/timeout_info_container.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/chapter_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/comment/comment_box.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/comment/comment_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/flow_tag.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/introduction_card.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/wenku_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class WebNovelDetailContainer extends StatelessWidget {
  const WebNovelDetailContainer(
    this.providerId,
    this.novelId, {
    super.key,
    this.openFromWeb = false,
  });
  final String novelId;
  final String providerId;

  final bool openFromWeb;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentCubit(),
      child: BlocSelector<WebHomeBloc, WebHomeState, WebNovelDto?>(
          selector: (state) {
        return state.currentWebNovelDto;
      }, builder: (context, novelDto) {
        return Scaffold(
          appBar: AppBar(
            shadowColor: styleManager.colorScheme(context).shadow,
            backgroundColor:
                styleManager.colorScheme(context).secondaryContainer,
            title: const Text('小说详情'),
            actions: _buildActions(context),
          ),
          drawer: Drawer(
            child: ChapterList(
              tocList: novelDto?.toc ?? [],
              novelKey: novelDto?.novelKey ?? '',
            ),
          ),
          body: _buildNovelDetailBody(novelDto),
        );
      }),
    );
  }

  BlocSelector<WebHomeBloc, WebHomeState, LoadingStatus?> _buildNovelDetailBody(
      WebNovelDto? novelDto) {
    return BlocSelector<WebHomeBloc, WebHomeState, LoadingStatus?>(
      selector: (state) {
        return state.loadingStatusMap[RequestLabel.loadNovelDetail];
      },
      builder: (context, state) {
        return TimeoutInfoContainer(
          status: state,
          child: novelDto == null
              ? Container()
              : WebNovelDetail(
                  novelDto: novelDto,
                  openFromWeb: openFromWeb,
                ),
          onRetry: () {
            readWebHomeBloc(context).add(WebHomeEvent.toNovelDetail(
              providerId,
              novelId,
            ));
          },
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      // IconButton(
      //   onPressed: () {
      //     // TODO 编辑
      //     Fluttertoast.showToast(msg: '这个功能还没有做呢');
      //   },
      //   icon: const Icon(UniconsLine.edit),
      // ),
      IconButton(
        onPressed: () {
          final host = readConfigCubit(context).state.host;
          final dto = readWebHomeBloc(context).state.currentWebNovelDto!;
          final url = 'https://$host/novel/${dto.providerId}/${dto.novelId}';
          Clipboard.setData(ClipboardData(text: url)).then((value) {
            showSucceedToast('小说链接已复制到剪切板');
          });
        },
        icon: const Icon(UniconsLine.link),
      ),
    ];
  }
}

class WebNovelDetail extends StatefulWidget {
  const WebNovelDetail({
    super.key,
    required this.novelDto,
    required this.openFromWeb,
  });

  final bool openFromWeb;
  final WebNovelDto novelDto;

  @override
  State<WebNovelDetail> createState() => _WebNovelDetailState();
}

class _WebNovelDetailState extends State<WebNovelDetail> {
  var scrollDirection = ScrollDirection.reverse;
  var shouldLoadMore = false;
  late PageLoader<Comment, Response<dynamic>> pageLoader;
  int currentPage = 0;
  late String novelKey;
  @override
  void initState() {
    novelKey = widget.novelDto.novelKey;
    final commentKey = 'web-$novelKey';
    super.initState();
    pageLoader = PageLoader(
      initPage: 0,
      pageSetter: (newPage) => currentPage = newPage,
      loader: () =>
          apiClient.commentService.getCommentList(commentKey, currentPage, 10),
      dataGetter: (data) => parseCommentList(data.body['items']),
      onLoadSucceed: (comments) =>
          readCommentCubit(context).addComments(comments),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageLoader.refresh();
      readCommentCubit(context).setSite(commentKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels > metrics.maxScrollExtent - 60) {
            if (shouldLoadMore && scrollDirection == ScrollDirection.forward) {
              shouldLoadMore = false;
              talker.debug('load next page!');
              pageLoader.loadMore();
            }
          } else {
            shouldLoadMore = true;
          }
        }
        if (notification is ScrollUpdateNotification) {
          final delta = notification.dragDetails;
          if (delta != null) {
            scrollDirection = delta.delta.dy > 0
                ? ScrollDirection.reverse
                : ScrollDirection.forward;
          }
        }
        return false;
      },
      child: PopScope(
        onPopInvoked: (_) {
          if (Scaffold.of(context).isDrawerOpen) return;
          readWebHomeBloc(context).add(const WebHomeEvent.leaveDetail());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: _buildNovelDetail(widget.novelDto, context),
        ),
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
        Text('评论', style: styleManager.boldMediumTitle(context)),
        const SizedBox(height: 8.0),
        CommentBox(onSucceedComment: () => pageLoader.refresh()),
        const SizedBox(height: 12.0),
        BlocSelector<CommentCubit, CommentState, List<Comment>>(
          selector: (state) => state.comments,
          builder: (context, comments) {
            return CommentList(comments: comments, parentCommentIds: const []);
          },
        ),
        const SizedBox(height: 64.0),
      ],
    );
  }

  Widget _buildAuthorInfo(WebNovelDto novelDto) {
    return Row(children: [
      Text('作者: ', style: styleManager.tipText(context)),
      Text(_getAuthors(novelDto),
          style: styleManager.tipText(context)?.copyWith(
                color: styleManager.colorScheme(context).primary,
              )),
    ]);
  }

  Widget _buildUpdateInfo(WebNovelDto novelDto) {
    return Row(
      children: [
        Text(novelDto.type, style: styleManager.tipText(context)),
        Text(' / ', style: styleManager.tipText(context)),
        Text('${parseLargeNumber(novelDto.totalCharacters ?? 0)} 字',
            style: styleManager.tipText(context)),
        Text(' / ', style: styleManager.tipText(context)),
        Text('${parseLargeNumber(novelDto.visited)} 浏览',
            style: styleManager.tipText(context)),
        Expanded(child: Container()),
        Text(
            '最近更新 ${parseTimeStamp((novelDto.toc?.last.createAt ?? 0) * 1000)}',
            style: styleManager.tipText(context)),
      ],
    );
  }

  List<Widget> _buildTitle(WebNovelDto novelDto) {
    return [
      Text(
        novelDto.titleJp,
        style: styleManager.primaryColorTitleLarge(context),
      ),
      Text(
        novelDto.titleZh ?? '',
        style: styleManager.greyTitleMedium(context),
      ),
    ];
  }

  List<Widget> _buildIntroduction(WebNovelDto novelDto) {
    return [
      Text(
        '简介',
        style: styleManager
            .textTheme(context)
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      IntroductionCard(
        content: novelDto.introductionZh ?? '',
        style: styleManager.textTheme(context).bodyMedium,
      ),
      IntroductionCard(
        content: novelDto.introductionJp,
        style: styleManager.tipText(context),
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
        child: _buildReadButton(context),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildFavorButton(context),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildToWenkuButton(context),
      ),
    ]);
  }

  Widget _buildToWenkuButton(BuildContext context) {
    return LineButton(
      enabled: widget.novelDto.wenkuId != null,
      onPressed: () {
        widget.openFromWeb ? Navigator.pop(context) : _toWenkuDetail(context);
      },
      onDisabledPressed: () => {showWarnToast('暂无文库')},
      text: '文库',
    );
  }

  void _toWenkuDetail(BuildContext context) {
    readWenkuHomeBloc(context).add(
      WenkuHomeEvent.toWenkuDetail(widget.novelDto.wenkuId!),
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const WenkuNovelDetailContainer(
                  openFromWeb: true,
                )));
  }

  BlocSelector<WebCacheCubit, WebCacheState, String?> _buildReadButton(
      BuildContext context) {
    return BlocSelector<WebCacheCubit, WebCacheState, String?>(
      selector: (state) {
        return readWebCacheCubit(context).state.lastReadChapterMap[novelKey];
      },
      builder: (context, lastReadChapterId) {
        return LineButton(
          onPressed: () => _readNovel(context, lastReadChapterId),
          text: (lastReadChapterId == null) ? '开始阅读' : '继续阅读',
        );
      },
    );
  }

  BlocSelector<FavoredCubit, FavoredState, String?> _buildFavorButton(
      BuildContext context) {
    return BlocSelector<FavoredCubit, FavoredState, String?>(
      selector: (state) {
        final novelId = readWebHomeBloc(context).currentNovelId;
        return state.novelToFavoredIdMap[novelId];
      },
      builder: (context, favoredStatus) {
        return LineButton(
            onPressed: () async {
              if (favoredStatus != null) {
                readWebHomeBloc(context)
                    .add(const WebHomeEvent.unFavorNovel(NovelType.web));
              } else {
                final favored = await _selectFavored(context);
                if (favored == null || !context.mounted) return;
                readWebHomeBloc(context).add(
                  WebHomeEvent.favorNovel(NovelType.web, favoredId: favored.id),
                );
              }
            },
            onDisabledPressed: () => showWarnToast('请先登录'),
            enabled: readUserCubit(context).isSignIn,
            text: (favoredStatus != null) ? '已收藏' : '收藏');
      },
    );
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

  Future<Favored?> _selectFavored(BuildContext context) async {
    final favoredList =
        readFavoredCubit(context).state.favoredMap[NovelType.web];
    if (favoredList == null || favoredList.isEmpty || favoredList.length == 1) {
      return Favored.createDefault();
    } else {
      return await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        constraints: BoxConstraints(
          minWidth: screenSize.width,
          maxHeight: screenSize.height * 0.8,
          minHeight: screenSize.height * 0.8,
        ),
        enableDrag: true,
        builder: (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '选择收藏夹',
                  textAlign: TextAlign.center,
                  style: styleManager.primaryColorTitleLarge(context),
                ),
              ),
              BlocSelector<FavoredCubit, FavoredState, List<Favored>>(
                selector: (state) {
                  return state.favoredMap[NovelType.web] ?? [];
                },
                builder: (context, state) {
                  return FavoredList(
                      favoredList: state,
                      type: NovelType.web,
                      editable: false,
                      onSelect: (favored) {
                        Navigator.pop(
                          context,
                          favored,
                        );
                      });
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
