import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/nav_title.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:unicons/unicons.dart';

class WebMostVisited extends StatelessWidget {
  const WebMostVisited({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNavTitle(),
        _buildWebMostVisited(),
      ],
    );
  }

  NavTitle _buildNavTitle() => NavTitle(
      title: '网络小说-最多点击',
      prefix: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UniconsLine.globe,
            size: 22,
          ),
          SizedBox(height: 3),
        ],
      ),
      jumpTo: () => {});

  Widget _buildWebMostVisited() {
    return BlocSelector<WebHomeBloc, WebHomeState, List<WebNovelOutline>>(
      selector: (state) {
        return state.webMostVisited ?? [];
      },
      builder: (context, webNovels) {
        return AnimationLimiter(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                AnimationConfiguration.staggeredGrid(
              duration: const Duration(milliseconds: 375),
              position: index,
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: WebNovelTile(novelOutline: webNovels[index]),
                ),
              ),
            ),
            itemCount: webNovels.length,
          ),
        );
      },
    );
  }
}
