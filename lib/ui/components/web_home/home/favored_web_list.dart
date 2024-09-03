import 'package:auto_novel_reader_flutter/bloc/user/user_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/nav_title.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:unicons/unicons.dart';

class FavoredWebList extends StatelessWidget {
  const FavoredWebList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) {
        return state.token != null;
      },
      builder: (context, isSignIn) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavTitle(isSignIn),
            isSignIn ? _buildFavoredWebList() : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  NavTitle _buildNavTitle(bool isSignIn) {
    return NavTitle(
        title: '我的收藏${isSignIn ? '' : '(请先登录)'}',
        prefix: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              UniconsLine.star,
              size: 22,
            ),
            SizedBox(height: 3),
          ],
        ),
        jumpTo: () {});
  }

  BlocSelector<WebHomeBloc, WebHomeState, List<WebNovel>>
      _buildFavoredWebList() {
    return BlocSelector<WebHomeBloc, WebHomeState, List<WebNovel>>(
      selector: (state) {
        return state.favoredWeb ?? [];
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
                          child: WebNovelTile(webNovel: webNovels[index])),
                    )),
            itemCount: webNovels.length,
          ),
        );
      },
    );
  }
}
