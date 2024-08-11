import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EpubWebview extends StatelessWidget {
  const EpubWebview({super.key, required this.htmlFilePath});
  final String htmlFilePath;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      readEpubViewerBloc(context).state.htmlData,
      customStylesBuilder: (element) {
        talker.info(element.styles);
        if (element.attributes['style'] == null) return null;
        if (element.attributes['style']!.contains('opacity:0.4')) {
          return {'color': 'lightgrey'};
        }
        return null;
      },
      onTapUrl: (element) {
        return true;
      },
    );
  }
}
