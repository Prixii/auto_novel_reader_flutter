import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/html_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    initData();
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

  void initData() {
    apiClient.userFavoredWebService
        .getIdList('/default', 0, 8, SearchSortType.update.value);
    apiClient.webNovelService.getList(
      0,
      8,
      provider: 'kakuyomu,syosetu,novelup,hameln,pixiv,alphapolis',
      sort: 1,
      level: 1,
    );
    apiClient.wenkuNovelService.getList(0, 12, level: 1);
  }
}
