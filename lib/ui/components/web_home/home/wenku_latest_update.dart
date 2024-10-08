import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/wenku_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class WenkuLatestUpdate extends StatelessWidget {
  const WenkuLatestUpdate({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildFavoredWebList();
  }

  Widget _buildFavoredWebList() {
    return BlocSelector<WenkuHomeBloc, WenkuHomeState, List<WenkuNovel>>(
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
