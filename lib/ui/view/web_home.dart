import 'package:auto_novel_reader_flutter/util/html_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
      onPressed: () {
        rootBundle.loadString('assets/html/3.html').then((html) {
          htmlUtil.paragraphExtractor(html);
        });
      },
      child: const Text('test'),
    ));
  }
}
