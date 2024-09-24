import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/reader/plain_text_painter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/reader_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
  TextStyle? style;
  List<PagedData> result = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final config = readConfigCubit(context).state.novelAppearanceConfig;

      style = TextStyle(
        color: Colors.black,
        fontSize: config.fontSize.toDouble(),
        fontWeight: config.boldFont ? FontWeight.bold : FontWeight.normal,
      );
      final resultText = await ReaderUtil.pagingText(
        widget.dto.youdaoParagraphs ?? [],
        pageSize,
        style!,
      );
      talker.debug(resultText.join('\n--------'));
      setState(() {
        result = resultText;
      });
    });
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
    final config = readConfigCubit(context).state.novelAppearanceConfig;
    style = TextStyle(
      color: Colors.black,
      fontSize: config.fontSize.toDouble(),
      fontWeight: config.boldFont ? FontWeight.bold : FontWeight.normal,
    );
    return (renderType == NovelRenderType.paged)
        ? _buildPagedViewer(context)
        : _buildStreamViewer(context);
  }

  Widget _buildPagedViewer(BuildContext context) {
    return PageView.builder(
        itemCount: result.length,
        itemBuilder: (context, index) {
          return buildSinglePage(
            result[index],
            size: pageSize,
            style: style!,
            paged: true,
          );
        });
  }

  Widget _buildStreamViewer(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        if (detail.velocity.pixelsPerSecond.dx < -standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) nextPage();
        } else if (detail.velocity.pixelsPerSecond.dx >
            standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) previousPage();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index == result.length) {
            return _buildBottomPageSwitcher();
          }
          return buildSinglePage(
            result[index],
            size: pageSize,
            style: style!,
            paged: false,
          );
        },
        itemCount: result.length + 1,
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
          child: ListView.builder(
              itemBuilder: (context, index) => buildContent(
                  pagedData.contents[index],
                  size: pageSize,
                  style: style),
              itemCount: pagedData.contents.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics()),
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
