import 'package:auto_novel_reader_flutter/ui/components/web_home/home/favored_web_list.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/web_most_visited.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/home/wenku_latest_update.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FavoredWebList(),
          WebMostVisited(),
          WenkuLatestUpdate(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
