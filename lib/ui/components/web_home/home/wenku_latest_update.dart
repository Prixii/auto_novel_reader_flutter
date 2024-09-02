import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/nav_title.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:unicons/unicons.dart';

class WenkuLatestUpdate extends StatelessWidget {
  const WenkuLatestUpdate({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNavTitle(),
        _buildFavoredWebList(),
      ],
    );
  }

  Widget _buildNavTitle() => NavTitle(
      title: '文库小说-最近更新',
      prefix: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UniconsLine.books,
            size: 22,
          ),
          SizedBox(height: 3),
        ],
      ),
      jumpTo: () => {});

  Widget _buildFavoredWebList() {
    return BlocSelector<WebHomeBloc, WebHomeState, List<WenkuNovel>>(
      selector: (state) {
        return state.wenkuLatestUpdate ?? [];
      },
      builder: (context, wenkuNovels) {
        return AnimationLimiter(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1 / 1.5,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                AnimationConfiguration.staggeredGrid(
              duration: const Duration(milliseconds: 375),
              position: index,
              columnCount: 3,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: WenkuNovelTile(wenkuNovel: wenkuNovels[index]),
                ),
              ),
            ),
            itemCount: wenkuNovels.length,
          ),
        );
      },
    );
  }
}
