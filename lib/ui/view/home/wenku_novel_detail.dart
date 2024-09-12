import 'package:auto_novel_reader_flutter/bloc/comment/comment_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/favored_cubit/favored_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/ui/components/favored/favored_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/comment/comment_box.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/comment/comment_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/flow_tag.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/introduction_card.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_detail/paged_cover.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel/download_list.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/web_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/page_loader.dart';
import 'package:auto_novel_reader_flutter/util/web_home_util.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class WenkuNovelDetailContainer extends StatelessWidget {
  const WenkuNovelDetailContainer({super.key, this.openFromWeb = false});

  final bool openFromWeb;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentCubit(),
      child: BlocSelector<WenkuHomeBloc, WenkuHomeState, WenkuNovelDto?>(
        selector: (state) {
          return state.loadingDetail ? null : state.currentWenkuNovelDto;
        },
        builder: (context, novelDto) {
          return Scaffold(
              appBar: AppBar(
                shadowColor: styleManager.colorScheme(context).shadow,
                backgroundColor:
                    styleManager.colorScheme(context).secondaryContainer,
                title: const Text('小说详情'),
                actions: _buildActions(context),
              ),
              body: (novelDto == null)
                  ? const Center(child: CircularProgressIndicator())
                  : WenkuNovelDetail(
                      novelDto: novelDto,
                      novelId: readWenkuHomeBloc(context).currentNovelId,
                      openFromWeb: openFromWeb,
                    ));
        },
      ),
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
          final novelId = readWenkuHomeBloc(context).currentNovelId;
          final url = 'https://$host/wenku/$novelId';
          Clipboard.setData(ClipboardData(text: url)).then((value) {
            showSucceedToast('小说链接已复制到剪切板');
          });
        },
        icon: const Icon(UniconsLine.link),
      ),
    ];
  }
}

class WenkuNovelDetail extends StatefulWidget {
  const WenkuNovelDetail(
      {super.key,
      required this.novelDto,
      required this.novelId,
      required this.openFromWeb});

  final WenkuNovelDto novelDto;
  final String novelId;
  final bool openFromWeb;

  @override
  State<WenkuNovelDetail> createState() => _WenkuNovelDetailState();
}

class _WenkuNovelDetailState extends State<WenkuNovelDetail> {
  late PageLoader<Comment, Response<dynamic>> pageLoader;
  int currentPage = 0;

  @override
  void initState() {
    final commentKey = 'wenku-${widget.novelId}';
    super.initState();
    pageLoader = PageLoader(
        pageSetter: (newPage) => currentPage = newPage,
        loader: () => apiClient.commentService
            .getCommentList(commentKey, currentPage, 10),
        dataGetter: (data) => parseCommentList(data.body['items']),
        onLoadSucceed: (comments) =>
            readCommentCubit(context).addComments(comments));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageLoader.refresh();
      readCommentCubit(context).setSite(commentKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: _buildNovelDetail(widget.novelDto, context),
    );
  }

  Widget _buildNovelDetail(WenkuNovelDto novelDto, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PagedCover(urls: _getCoverUrls(novelDto)),
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
      Text('作者: ', style: styleManager.tipText(context)),
      Text(_uniteMembers(novelDto.authors),
          style: styleManager.tipText(context)?.copyWith(
                color: styleManager.colorScheme(context).primary,
              )),
    ]);
  }

  Widget _buildArtistsInfo(WenkuNovelDto novelDto) {
    return Row(children: [
      Text('插图: ', style: styleManager.tipText(context)),
      Text(_uniteMembers(novelDto.artists),
          style: styleManager.tipText(context)?.copyWith(
                color: styleManager.colorScheme(context).primary,
              )),
    ]);
  }

  Widget _buildPublisherInfo(WenkuNovelDto novelDto) {
    return Row(children: [
      Text('出版: ', style: styleManager.tipText(context)),
      Expanded(
        child: Text(
          '${novelDto.publisher} ',
          style: styleManager.tipText(context)?.copyWith(
                color: styleManager.colorScheme(context).primary,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(
        child: Text(
          novelDto.imprint ?? '',
          style: styleManager.tipText(context)?.copyWith(
                color: styleManager.colorScheme(context).primary,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _buildUpdateInfo(WenkuNovelDto novelDto) {
    return Row(
      children: [
        Text(novelDto.level, style: styleManager.tipText(context)),
        Text(' / ', style: styleManager.tipText(context)),
        Text('共 ${novelDto.volumes.length} 卷',
            style: styleManager.tipText(context)),
        Text(' / ', style: styleManager.tipText(context)),
        Text('${parseLargeNumber(novelDto.visited)} 浏览',
            style: styleManager.tipText(context)),
        Expanded(child: Container()),
        Text('最新出版 ${parseTimeStamp((novelDto.latestPublishAt ?? 0) * 1000)}',
            style: styleManager.tipText(context)),
      ],
    );
  }

  List<Widget> _buildTitle(WenkuNovelDto novelDto) {
    return [
      Text(
        novelDto.title,
        style: styleManager.primaryColorTitleLarge(context),
      ),
      Text(
        novelDto.titleZh,
        style: styleManager.greyTitleMedium(context),
      ),
    ];
  }

  List<Widget> _buildIntroduction(WenkuNovelDto novelDto) {
    return [
      Text(
        '简介',
        style: styleManager
            .textTheme(context)
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      IntroductionCard(
        content: novelDto.introduction,
        style: styleManager.textTheme(context).bodyMedium,
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
        child: _buildReadButton(context),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildFavoredButton(),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildToWebButton(context),
      )
    ]);
  }

  Widget _buildToWebButton(BuildContext context) {
    return LineButton(
      enabled: widget.novelDto.webIds.isNotEmpty,
      onPressed: () {
        widget.openFromWeb ? Navigator.pop(context) : toWebDetail(context);
      },
      onDisabledPressed: () => {showWarnToast('暂无 Web')},
      text: 'Web',
    );
  }

  void toWebDetail(BuildContext context) {
    final webIdData = widget.novelDto.webIds.first.split('/');
    final providerId = webIdData[0].trim();
    final novelId = webIdData[1].trim();
    readWebHomeBloc(context)
        .add(WebHomeEvent.toNovelDetail(providerId, novelId));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => WebNovelDetailContainer(
                  providerId,
                  novelId,
                  openFromWeb: true,
                )));
  }

  LineButton _buildReadButton(BuildContext context) {
    return LineButton(
      enabled: readUserCubit(context).isSignIn,
      onPressed: () => _toDownload(context),
      onDisabledPressed: () => showWarnToast('请先登录'),
      text: '阅读',
    );
  }

  BlocSelector<FavoredCubit, FavoredState, String?> _buildFavoredButton() {
    return BlocSelector<FavoredCubit, FavoredState, String?>(
      selector: (state) {
        return state.novelToFavoredIdMap[widget.novelId];
      },
      builder: (context, favoredStatus) {
        return LineButton(
            onPressed: () async {
              if (favoredStatus != null) {
                readWenkuHomeBloc(context)
                    .add(WenkuHomeEvent.unFavorNovel(novelId: widget.novelId));
              } else {
                final favored = await _selectFavored(context);
                if (favored == null || !context.mounted) return;
                readWenkuHomeBloc(context).add(
                  WenkuHomeEvent.favorNovel(
                    novelId: widget.novelId,
                    favoredId: favored.id,
                  ),
                );
              }
            },
            onDisabledPressed: () => showWarnToast('请先登录'),
            enabled: readUserCubit(context).isSignIn,
            text: (favoredStatus != null) ? '已收藏' : '收藏');
      },
    );
  }

  _toDownload(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DownloadList()));
  }

  Future<Favored?> _selectFavored(BuildContext context) async {
    final favoredList =
        readFavoredCubit(context).state.favoredMap[NovelType.wenku];
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
                  return state.favoredMap[NovelType.wenku] ?? [];
                },
                builder: (context, state) {
                  return FavoredList(
                      favoredList: state,
                      type: NovelType.wenku,
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
