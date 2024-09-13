import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/home.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_rank/novel_rank.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/web_novel_search_page.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel/wenku_novel_search_page.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/web_novel_detail.dart';
import 'package:auto_novel_reader_flutter/ui/view/home/wenku_novel_detail.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: styleManager.colorScheme(context).shadow,
          backgroundColor: styleManager.colorScheme(context).secondaryContainer,
          title: _buildTabBar(),
          actions: [
            IconButton(
              onPressed: () {
                _showDialog(context);
              },
              icon: const Icon(UniconsLine.link_add),
              tooltip: '解析 url',
            )
          ],
        ),
        body: const TabBarView(
          children: [
            Home(),
            WebNovelSearchPage(),
            WenkuNovelSearchPage(),
            NovelRank(),
          ],
        ),
      ),
    );
  }

  TabBar _buildTabBar() {
    return const TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: [
        Tab(text: '首页'),
        Tab(text: '网络'),
        Tab(text: '文库'),
        Tab(text: '排行'),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('链接解析'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: '通过 Web 链接打开小说'),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 处理提交逻辑
                String inputText = controller.text;
                final result = _parseUrl(inputText);
                if (result != null) {
                  if (result.$1 == NovelType.web) {
                    readWebHomeBloc(context).add(WebHomeEvent.toNovelDetail(
                        result.$2[0]!, result.$2[1]!));
                    Navigator.of(context).pop(); // 关闭对话框
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WebNovelDetailContainer(
                                result.$2[0]!, result.$2[1]!)));
                  }
                  if (result.$1 == NovelType.wenku) {
                    final wenkuId = result.$2[0]!;
                    readWenkuHomeBloc(context)
                        .add(WenkuHomeEvent.toWenkuDetail(wenkuId));
                    Navigator.of(context).pop(); // 关闭对话框
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                WenkuNovelDetailContainer(wenkuId)));
                  }
                }
              },
              child: const Text('解析'),
            ),
          ],
        );
      },
    );
  }

  (NovelType, List<String?>)? _parseUrl(String url) {
    final novelPattern = RegExp(r'novel/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)');
    final wenkuPattern = RegExp(r'wenku/([a-zA-Z0-9]+)');
    (NovelType, List<String?>)? result;
    // 检查是否为novel类型URL
    final novelMatch = novelPattern.firstMatch(url);
    if (novelMatch != null) {
      final novel = [novelMatch.group(1), novelMatch.group(2)];
      result = (NovelType.web, novel);
    }
    final wenkuMatch = wenkuPattern.firstMatch(url);
    if (wenkuMatch != null) {
      final wenku = [wenkuMatch.group(1)];
      result = (NovelType.wenku, wenku);
    }

    talker.debug(result);
    if (result == null) {
      showErrorToast('不支持的URL');
    }

    return result;
  }
}
