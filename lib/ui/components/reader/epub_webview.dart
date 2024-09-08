import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/info_badge.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

const standardSwitchPageVelocity = 100.0;

class EpubWebview extends StatefulWidget {
  const EpubWebview({super.key});

  @override
  State<EpubWebview> createState() => _EpubWebviewState();
}

class _EpubWebviewState extends State<EpubWebview> {
  late ScrollController _scrollController;
  double readProgress = 0.0;
  var maxHeight = 0.0;

  @override
  void initState() {
    super.initState();
    initScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      maxHeight = MediaQuery.of(context).size.height * 0.7;
      readEpubViewerBloc(context)
          .add(EpubViewerEvent.setScrollController(_scrollController));
    });
  }

  void initScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final position = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;
      setState(() {
        readProgress = position / max;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EpubViewerBloc, EpubViewerState, List<String>>(
      selector: (state) {
        return state.htmlData;
      },
      builder: (context, htmlDataList) {
        return PopScope(
          onPopInvoked: (value) {
            if (Scaffold.of(context).isDrawerOpen) return;
            readEpubViewerBloc(context)
                .add(EpubViewerEvent.close(readProgress));
          },
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              _buildReaderBody(htmlDataList),
              Align(
                alignment: Alignment.topRight,
                child: _buildChapterInfo(),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _buildChapterProgress(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildProgressBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReaderBody(List<String> htmlDataList) {
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        if (detail.velocity.pixelsPerSecond.dx < -standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) nextPage();
        } else if (detail.velocity.pixelsPerSecond.dx >
            standardSwitchPageVelocity) {
          if (readConfigCubit(context).state.slideShift) previousPage();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: htmlDataList.length + 1,
            itemBuilder: (context, index) {
              return (index == htmlDataList.length)
                  ? _buildBottomPageSwitcher()
                  : _buildHtmlWidget(htmlDataList, index, context);
            }),
      ),
    );
  }

  HtmlWidget _buildHtmlWidget(
      List<String> htmlDataList, int index, BuildContext context) {
    return HtmlWidget(
      htmlDataList[index],
      customStylesBuilder: (element) {
        if (element.attributes['style'] == null && element.localName != 'p') {
          return null;
        }
        return _buildStylesMap(element.attributes['style'] ?? '');
      },
      buildAsync: false,
      onErrorBuilder: (_, element, error) {
        return readConfigCubit(context).state.showErrorInfo
            ? Text('error: $error\nelement: ${element.outerHtml}\n ')
            : const SizedBox.shrink();
      },
      onTapUrl: (element) {
        readEpubViewerBloc(context).add(EpubViewerEvent.clickUrl(element));
        return true;
      },
    );
  }

  Map<String, String> _buildStylesMap(String style) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final styles = style.split(RegExp(r';|:'));
    var stylesMap = <String, String>{};
    for (int i = 0; i < styles.length; i += 2) {
      final key = styles[i].trim();
      if (key == '') continue;
      final value = styles[i + 1].trim();
      stylesMap[key] = value;
    }
    if (stylesMap.containsKey('opacity')) {
      stylesMap['color'] = isDark ? 'grey' : 'lightgrey';
    } else {
      if (isDark) {
        final color = styleManager.colorScheme(context).primary;
        stylesMap['color'] = 'rgb(${color.red},${color.green},${color.blue})';
      }
    }
    return stylesMap;
  }

  Widget _buildBottomPageSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(onPressed: previousPage, child: const Text('上一页')),
        TextButton(onPressed: nextPage, child: const Text('下一页'))
      ],
    );
  }

  void nextPage() {
    talker.debug('nextPage!');
    readProgress = 0.0;
    readEpubViewerBloc(context).add(const EpubViewerEvent.nextChapter());
  }

  void previousPage() {
    talker.debug('previousPage!');
    readProgress = 0.0;
    readEpubViewerBloc(context).add(const EpubViewerEvent.previousChapter());
  }

  Widget _buildChapterInfo() {
    return BlocSelector<EpubViewerBloc, EpubViewerState, int>(
      selector: (state) {
        return state.currentChapterIndex;
      },
      builder: (context, chapterIndex) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildInfoBadge('第${chapterIndex + 1}章'),
        );
      },
    );
  }

  Widget _buildChapterProgress() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildInfoBadge('${(readProgress * 100).floor()}%'),
    );
  }

  Widget _buildInfoBadge(String info) {
    return InfoBadge(info);
  }

  Widget _buildProgressBar() {
    const horizontalPadding = 10.0;
    const radius = 4.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (detail) {
        slideTo(detail.localPosition.dy / maxHeight);
      },
      onLongPressMoveUpdate: (details) {
        slideTo(details.localPosition.dy / maxHeight);
      },
      child: SizedBox(
        width: 2 * (radius + horizontalPadding),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Stack(
            children: [
              Container(
                  height: maxHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: Colors.grey.withOpacity(0.5),
                  )),
              Container(
                decoration: BoxDecoration(
                  color: styleManager.colorScheme(context).secondary,
                  borderRadius: BorderRadius.circular(radius),
                ),
                height: maxHeight * readProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void slideTo(double progress) {
    if (progress < 0 || progress > 1) return;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        progress * _scrollController.position.maxScrollExtent,
      );
    }
  }
}
