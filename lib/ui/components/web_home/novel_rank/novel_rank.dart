import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_rank/filters.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_rank/rank_selector.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/novel_rank/rank_novel_list.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class NovelRank extends StatefulWidget {
  const NovelRank({super.key});

  @override
  State<NovelRank> createState() => _NovelRankState();
}

class _NovelRankState extends State<NovelRank>
    with SingleTickerProviderStateMixin {
  late PageController _novelListPageController;
  late PageController _novelFilterPageController;
  bool _isFilterVisible = false;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late CurvedAnimation _curvedScaleAnimation;
  late CurvedAnimation _curvedFadeAnimation;
  late AnimationController _animationController;
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _novelListPageController = PageController();
    _novelFilterPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rankBloc = readNovelRankBloc(context);
      if ((rankBloc.state.novels[RankCategory.values.first] ?? []).isEmpty) {
        rankBloc.add(NovelRankEvent.searchRankNovel(RankCategory.values.first));
      }
    });
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // 使用 CurvedAnimation 添加曲线效果
    _curvedScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc, // 选择曲线
    );

    _curvedFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc, // 选择曲线
    );

    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(_curvedScaleAnimation);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_curvedFadeAnimation);
  }

  @override
  void dispose() {
    _novelListPageController.dispose();
    _novelFilterPageController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        PageView(
          controller: _novelListPageController,
          physics: const NeverScrollableScrollPhysics(), // 禁止滑动
          children: RankCategory.values
              .map((e) => RankNovelList(rankCategory: e))
              .toList(),
        ),
        SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: RankSelector(
                    label: '分类',
                    onTap: (_, index) => _toPage(index),
                    tabs: RankCategory.values.map((e) => e.zhName).toList()),
              ),
              IconButton(
                  onPressed: _toggleVisibility,
                  icon: Icon(UniconsLine.sort_amount_down,
                      color: styleManager.colorScheme.onSecondaryContainer)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 68, left: 16, right: 16),
          child: Visibility(
              visible: _isFilterVisible, child: _buildAnimatedFilter()),
        ),
      ],
    );
  }

  Widget _buildAnimatedFilter() {
    final filterList = [
      _buildBlurContainer(const SyosetuGenreFilter()),
      _buildBlurContainer(const SyosetuComprehensiveFilter()),
      _buildBlurContainer(const SyosetuIsekaiFilter()),
      _buildBlurContainer(const KakuyomuGenreFilters()),
    ];
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15))],
              color: styleManager.colorScheme.surface.withOpacity(0.6)),
          child: filterList[currentIndex],
        ),
      ),
    );
  }

  Widget _buildBlurContainer(Widget child) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: child,
    );
  }

  void _toggleVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
      if (_isFilterVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toPage(int index) {
    if (index >= RankCategory.values.length) return; // 确保不超出页面范围
    setState(() {
      currentIndex = index;
    });
    final webNovels =
        readNovelRankBloc(context).state.novels[RankCategory.values[index]];
    if (webNovels == null || webNovels.isEmpty) {
      readNovelRankBloc(context)
          .add(NovelRankEvent.searchRankNovel(RankCategory.values[index]));
    }
    _novelListPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
