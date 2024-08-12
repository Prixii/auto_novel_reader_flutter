import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final position = _scrollController.offset;
      final max = _scrollController.position.maxScrollExtent;
      setState(() {
        readProgress = position / max;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      maxHeight = MediaQuery.of(context).size.height * 0.7;
      readEpubViewerBloc(context)
          .add(EpubViewerEvent.setScrollController(_scrollController));
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
            readEpubViewerBloc(context).add(const EpubViewerEvent.close());
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
        if (detail.velocity.pixelsPerSecond.dx < 0) {
          nextPage();
        } else {
          previousPage();
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32),
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: htmlDataList.length + 1,
              itemBuilder: (context, index) {
                return (index == htmlDataList.length)
                    ? _buildBottomPageSwitcher()
                    : _buildHtmlWidget(htmlDataList, index, context);
              }),
        ),
      ),
    );
  }

  HtmlWidget _buildHtmlWidget(
      List<String> htmlDataList, int index, BuildContext context) {
    return HtmlWidget(
      htmlDataList[index],
      customStylesBuilder: (element) {
        if (element.attributes['style'] == null) return null;
        if (element.attributes['style']!.contains('opacity:0.4')) {
          return {'color': 'lightgrey'};
        }
        return null;
      },
      buildAsync: false,
      onTapUrl: (element) {
        readEpubViewerBloc(context).add(EpubViewerEvent.clickUrl(element));
        return true;
      },
      baseUrl: Uri(path: epubUtil.currentPath),
    );
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
    readEpubViewerBloc(context).add(const EpubViewerEvent.nextChapter());
  }

  void previousPage() {
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

  Container _buildInfoBadge(String info) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.withOpacity(0.5),
        ),
        child: Text(
          info,
          style: const TextStyle(color: Colors.white),
        ));
  }

  Widget _buildProgressBar() {
    return GestureDetector(
      onTapDown: (detail) {
        slideTo(detail.localPosition.dy / maxHeight);
      },
      onLongPressMoveUpdate: (details) {
        slideTo(details.localPosition.dy / maxHeight);
      },
      child: Container(
        height: maxHeight,
        width: 20,
        padding: const EdgeInsets.only(left: 4, right: 10),
        child: Stack(
          children: [
            Container(
                height: maxHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.withOpacity(0.5),
                )),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
              height: maxHeight * readProgress,
            ),
          ],
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
