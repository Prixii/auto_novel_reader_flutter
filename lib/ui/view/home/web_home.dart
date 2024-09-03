import 'package:auto_novel_reader_flutter/ui/components/web_home/home/home.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_rank/novel_rank.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/web_novel.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel/wenku_novel.dart';
import 'package:flutter/material.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Theme.of(context).colorScheme.shadow,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: _buildTabBar(),
        ),
        body: const TabBarView(
          children: [
            Home(),
            WebNovel(),
            WenkuNovel(),
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
}
