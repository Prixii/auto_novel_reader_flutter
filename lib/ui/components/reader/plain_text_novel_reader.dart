import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/paged/paginated_novel_render.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/chapter_list.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlainTextNovelReaderContainer extends StatelessWidget {
  const PlainTextNovelReaderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WebHomeBloc, WebHomeState, ChapterDto?>(
      selector: (state) {
        return state.currentChapterDto;
      },
      builder: (context, dto) {
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(dto?.titleJp ?? dto?.titleZh ?? ''),
          //   shadowColor: styleManager.colorScheme(context).shadow,
          //   backgroundColor:
          //       styleManager.colorScheme(context).secondaryContainer,
          //   actions: _buildActions(context),
          // ),
          drawer: Drawer(
            child: BlocSelector<WebHomeBloc, WebHomeState, WebNovelDto?>(
              selector: (state) {
                final dto = state.currentWebNovelDto!;
                return state.webNovelDtoMap[dto.novelKey];
              },
              builder: (context, novelDto) {
                final state = readWebHomeBloc(context).state;
                final dto = state.currentWebNovelDto!;
                return ChapterList(
                  tocList: novelDto?.toc ?? [],
                  readMode: true,
                  novelKey: dto.novelKey,
                );
              },
            ),
          ),
          body: dto == null
              ? const Center(child: CircularProgressIndicator())
              : PlainTextNovelReader(dto: dto),
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      //  TODO 编辑
      // IconButton(
      //   onPressed: () {
      //     Fluttertoast.showToast(msg: '这个功能还没有做呢');
      //   },
      //   icon: const Icon(UniconsLine.edit),
      // ),
      IconButton(
        onPressed: () {
          final host = readConfigCubit(context).state.host;
          final dto = readWebHomeBloc(context).state.currentWebNovelDto!;
          final chapterId =
              readWebCacheCubit(context).state.lastReadChapterMap[dto.novelKey];
          final url =
              'https://$host/novel/${dto.providerId}/${dto.novelId}/$chapterId';
          Clipboard.setData(ClipboardData(text: url)).then((value) {
            showSucceedToast('章节链接已复制到剪切板');
          });
        },
        icon: const Icon(UniconsLine.link),
      ),
    ];
  }
}

class PlainTextNovelReader extends StatefulWidget {
  const PlainTextNovelReader({
    super.key,
    required this.dto,
  });

  final ChapterDto dto;

  @override
  State<PlainTextNovelReader> createState() => _PlainTextNovelReaderState();
}

class _PlainTextNovelReaderState extends State<PlainTextNovelReader>
    with TickerProviderStateMixin {
  late AnimationController _maskAnimationController;
  late Animation<double> _maskAnimation;

  List<String> result = [];
  late NovelRenderType renderType;

  @override
  void initState() {
    super.initState();
    renderType =
        readConfigCubit(context).state.novelAppearanceConfig.renderType;
    _maskAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _maskAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_maskAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        if (Scaffold.of(context).isDrawerOpen) return;
        if (readConfigCubit(context).state.keepAwakeWhenReading) {
          WakelockPlus.disable();
        }
        readWebHomeBloc(context).add(const WebHomeEvent.closeNovel());
      },
      child: Stack(
        children: [
          _buildNovelRender(),
          _buildLoadingMask(),
        ],
      ),
    );
  }

  Widget _buildNovelRender() {
    return BlocSelector<WebHomeBloc, WebHomeState, bool>(
      selector: (state) {
        return state.loadingNovelChapter;
      },
      builder: (context, isLoading) {
        return AbsorbPointer(
          absorbing: isLoading,
          child: PaginatedNovelRender(dto: widget.dto),
        );
      },
    );
  }

  Widget _buildLoadingMask() {
    return BlocListener<WebHomeBloc, WebHomeState>(
        listener: (context, state) {
          if (state.loadingNovelChapter) {
            _maskAnimationController.forward();
          } else {
            _maskAnimationController.reverse();
          }
        },
        listenWhen: (previous, current) {
          return previous.loadingNovelChapter != current.loadingNovelChapter;
        },
        child: FadeTransition(
          opacity: _maskAnimation,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ));
  }
}
