import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EpubWebview extends StatelessWidget {
  const EpubWebview({super.key, required this.htmlFilePath});
  final String htmlFilePath;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<EpubViewerBloc, EpubViewerState, String>(
      selector: (state) {
        return state.htmlData;
      },
      builder: (context, htmlData) {
        return GestureDetector(
          onTap: () {
            talker.info('try next');
            readEpubViewerBloc(context)
                .add(const EpubViewerEvent.nextChapter());
          },
          onLongPress: () => readEpubViewerBloc(context)
              .add(const EpubViewerEvent.previousChapter()),
          child: HtmlWidget(
            htmlData,
            customStylesBuilder: (element) {
              if (element.attributes['style'] == null) return null;
              if (element.attributes['style']!.contains('opacity:0.4')) {
                return {'color': 'lightgrey'};
              }
              return null;
            },
            onTapUrl: (element) {
              return true;
            },
          ),
        );
      },
    );
  }
}
