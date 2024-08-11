import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/epub_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EpubWebview extends StatefulWidget {
  const EpubWebview({super.key, required this.htmlFilePath});
  final String htmlFilePath;

  @override
  State<EpubWebview> createState() => _EpubWebviewState();
}

class _EpubWebviewState extends State<EpubWebview> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
          child: GestureDetector(
            onTap: () {
              talker.info('try next');
              readEpubViewerBloc(context)
                  .add(const EpubViewerEvent.nextChapter());
            },
            onLongPress: () => readEpubViewerBloc(context)
                .add(const EpubViewerEvent.previousChapter()),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: htmlDataList.length,
                    itemBuilder: (context, index) {
                      return _buildHtmlWidget(htmlDataList, index, context);
                    }),
              ),
            ),
          ),
        );
      },
    );
  }

  HtmlWidget _buildHtmlWidget(
      List<String> htmlDataList, int index, BuildContext context) {
    return HtmlWidget(htmlDataList[index],
        customStylesBuilder: (element) {
          if (element.attributes['style'] == null) return null;
          if (element.attributes['style']!.contains('opacity:0.4')) {
            return {'color': 'lightgrey'};
          }
          return null;
        },
        buildAsync: true,
        onTapUrl: (element) {
          readEpubViewerBloc(context).add(EpubViewerEvent.clickUrl(element));
          return true;
        },
        baseUrl: Uri(path: epubUtil.currentPath));
  }
}
