import 'package:auto_novel_reader_flutter/ui/view/reader/local_book.dart';
import 'package:flutter/material.dart';

class ReaderView extends StatelessWidget {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shadowColor: Theme.of(context).colorScheme.shadow,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: _buildTabBar(),
        ),
        body: const TabBarView(
          children: [
            LocalBookView(),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
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
        Tab(text: '本地'),
        Tab(text: '历史'),
        Tab(text: '收藏'),
      ],
    );
  }
}
