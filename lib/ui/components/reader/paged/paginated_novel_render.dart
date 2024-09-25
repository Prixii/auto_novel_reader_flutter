import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_painter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const standardSwitchPageVelocity = 100.0;

class PaginatedNovelRender extends StatefulWidget {
  const PaginatedNovelRender({
    super.key,
    required this.dto,
  });
  final ChapterDto dto;

  @override
  State<PaginatedNovelRender> createState() => _PaginatedNovelRenderState();
}

class _PaginatedNovelRenderState extends State<PaginatedNovelRender> {
  late ScrollController _scrollController;
  late PageController _pageController;
  int currentPage = 0;
  var switchable = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderType =
        readConfigCubit(context).state.novelAppearanceConfig.renderType;
    return (renderType == NovelRenderType.paged)
        ? _buildPagedViewer(context)
        : _buildStreamViewer(context);
  }

  Widget _buildPagedViewer(BuildContext context) {
    return BlocSelector<WebHomeBloc, WebHomeState, List<PagedData>?>(
      selector: (state) {
        return state.currentPagedData;
      },
      builder: (context, pageData) {
        if (pageData == null) return const Text('damn');
        return Stack(children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollEndNotification &&
                  switchable &&
                  notification.metrics.extentAfter == 0) {
                nextChapter();
              } else if (notification is ScrollEndNotification &&
                  switchable &&
                  notification.metrics.extentBefore == 0) {
                previousChapter();
              }
              return false;
            },
            child: PageView.builder(
                itemCount: pageData.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    switchable = index == 0 || index == pageData.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: buildSinglePage(
                      pageData[index],
                      size: pageSize,
                      paged: true,
                    ),
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: margin.$1 / 2, vertical: margin.$2 / 2),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.dto.titleZh ?? widget.dto.titleJp ?? '',
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${currentPage + 1}/${pageData.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildStreamViewer(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        if (detail.velocity.pixelsPerSecond.dx < -standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) nextChapter();
        } else if (detail.velocity.pixelsPerSecond.dx >
            standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) previousChapter();
        }
      },
      child: BlocSelector<WebHomeBloc, WebHomeState, List<PagedData>?>(
        selector: (state) {
          return state.currentPagedData;
        },
        builder: (context, pageData) {
          if (pageData == null) return const Text('damn');
          return ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == pageData.length) {
                return _buildBottomPageSwitcher();
              }
              return buildSinglePage(
                pageData[index],
                size: pageSize,
                paged: false,
              );
            },
            itemCount: pageData.length + 1,
          );
        },
      ),
    );
  }

  Widget buildSinglePage(
    PagedData pagedData, {
    required Size size,
    bool paged = false,
  }) =>
      Padding(
        padding:
            EdgeInsets.symmetric(horizontal: margin.$1, vertical: margin.$2),
        child: SizedBox(
          width: size.width,
          height: paged ? size.height : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: pagedData.contents
                .map((content) => buildContent(
                      content,
                      size: pageSize,
                    ))
                .toList(),
          ),
        ),
      );

  Widget buildContent(
    WebContent content, {
    required Size size,
  }) {
    switch (content.type) {
      case WebNovelContentType.original:
        final style =
            readConfigCubit(context).state.novelAppearanceConfig.textStyle;
        return buildPagedText(content, size: size, style: style);
      case WebNovelContentType.translation:
        final style =
            readConfigCubit(context).state.novelAppearanceConfig.subTextStyle;
        return buildPagedText(content, size: size, style: style);
      case WebNovelContentType.image:
        return buildImage(content);
    }
  }

  CustomPaint buildPagedText(
    WebContent content, {
    required Size size,
    required TextStyle style,
  }) =>
      CustomPaint(
          size: Size(size.width, content.height),
          painter: PlainTextPainter(
            text: content.text,
            style: style,
            size: Size(size.width, content.height),
          ));

  Widget buildImage(WebContent content) => Center(
        child: CachedNetworkImage(
          imageUrl: content.imgUrl,
          fit: BoxFit.contain,
          height: content.height,
          width: content.width,
        ),
      );

  Widget _buildBottomPageSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(onPressed: previousChapter, child: const Text('上一章')),
        TextButton(onPressed: nextChapter, child: const Text('下一章'))
      ],
    );
  }

  void nextChapter() {
    switchable = false;
    readWebHomeBloc(context).add(const WebHomeEvent.nextChapter());
    setState(() {
      currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  void previousChapter() {
    switchable = false;
    readWebHomeBloc(context).add(const WebHomeEvent.previousChapter());
    setState(() {
      currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  Size get pageSize {
    final config = readConfigCubit(context).state.novelAppearanceConfig;
    return Size(
      screenSize.width - 2 * config.horizontalMargin,
      screenSize.height - 2 * config.verticalMargin,
    );
  }

  (double horizontal, double vertical) get margin {
    final config = readConfigCubit(context).state.novelAppearanceConfig;
    return (
      config.horizontalMargin,
      config.verticalMargin,
    );
  }
}
