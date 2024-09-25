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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final style =
        readConfigCubit(context).state.novelAppearanceConfig.textStyle;
    return BlocSelector<WebHomeBloc, WebHomeState, List<PagedData>?>(
      selector: (state) {
        return state.currentPagedData;
      },
      builder: (context, state) {
        if (state == null) return const Text('damn');
        return PageView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              return Center(
                child: buildSinglePage(
                  state[index],
                  size: pageSize,
                  style: style,
                  paged: true,
                ),
              );
            });
      },
    );
  }

  Widget _buildStreamViewer(BuildContext context) {
    final style =
        readConfigCubit(context).state.novelAppearanceConfig.textStyle;
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        if (detail.velocity.pixelsPerSecond.dx < -standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) nextPage();
        } else if (detail.velocity.pixelsPerSecond.dx >
            standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) previousPage();
        }
      },
      child: BlocSelector<WebHomeBloc, WebHomeState, List<PagedData>?>(
        selector: (state) {
          return state.currentPagedData;
        },
        builder: (context, result) {
          if (result == null) return const Text('damn');
          return ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == result.length) {
                return _buildBottomPageSwitcher();
              }
              return buildSinglePage(
                result[index],
                size: pageSize,
                style: style,
                paged: false,
              );
            },
            itemCount: result.length + 1,
          );
        },
      ),
    );
  }

  Widget buildSinglePage(
    PagedData pagedData, {
    required Size size,
    required TextStyle style,
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
                  .map((content) =>
                      buildContent(content, size: pageSize, style: style))
                  .toList()),
        ),
      );

  Widget buildContent(
    WebContent content, {
    required Size size,
    required TextStyle style,
  }) {
    switch (content.type) {
      case WebNovelContentType.original:
      case WebNovelContentType.translation:
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
        TextButton(onPressed: previousPage, child: const Text('上一章')),
        TextButton(onPressed: nextPage, child: const Text('下一章'))
      ],
    );
  }

  void nextPage() {
    readWebHomeBloc(context).add(const WebHomeEvent.nextChapter());
  }

  void previousPage() {
    readWebHomeBloc(context).add(const WebHomeEvent.previousChapter());
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
