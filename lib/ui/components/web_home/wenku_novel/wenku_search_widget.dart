import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class WenkuSearchWidget extends StatefulWidget {
  const WenkuSearchWidget({super.key});

  @override
  State<WenkuSearchWidget> createState() => _WenkuSearchWidgetState();
}

class _WenkuSearchWidgetState extends State<WenkuSearchWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late CurvedAnimation _curvedScaleAnimation;
  late CurvedAnimation _curvedFadeAnimation;
  late RadioFilterController _levelController;

  bool _isFilterVisible = false;
  // bool _isHistoryVisible = false;
  // TODO 历史搜索
  @override
  void initState() {
    super.initState();

    _initAnimation();

    _levelController = RadioFilterController();
    _searchController = TextEditingController();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Visibility(
        visible: _isFilterVisible,
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: () => _toggleVisibility(false),
          child: Container(color: Colors.transparent),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            _buildAnimatedFilter()
          ],
        ),
      ),
    ]);
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: styleManager.colorScheme(context).secondaryContainer, // 设置底色
        borderRadius: BorderRadius.circular(24), // 圆角
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '中/日文标题或作者',
          hintStyle: TextStyle(
              color: styleManager
                  .colorScheme(context)
                  .secondaryFixedDim), // 提示文本颜色
          border: InputBorder.none, // 去掉默认边框
          prefixIcon: Icon(Icons.search,
              color:
                  styleManager.colorScheme(context).secondaryFixedDim), // 搜索图标
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 内边距
        ),
        onTap: () => _toggleVisibility(true),
        maxLines: 1,
        onSubmitted: (_) {
          _search();
          _toggleVisibility(false);
        },
        style: TextStyle(
            color: styleManager
                .colorScheme(context)
                .onSecondaryContainer), // 输入文本颜色
      ),
    );
  }

  Widget _buildAnimatedFilter() {
    return Visibility(
      visible: _isFilterVisible,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15))],
                color:
                    styleManager.colorScheme(context).surface.withOpacity(0.6)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: _buildFilters(),
            ),
          ),
        ),
      ),
    );
  }

  Column _buildFilters() {
    final isOldAss = readUserCubit(context).isOldAss;
    final levelList =
        isOldAss ? WenkuNovelLevel.values : WenkuNovelLevel.youngAss;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: double.infinity,
        child: RadioFilter(
            title: '分级',
            controller: _levelController,
            values: levelList,
            options: levelList.map((e) => e.zhName).toList()),
      ),
    ]);
  }

  void _toggleVisibility(bool value) {
    if (_isFilterVisible == value) return;
    setState(() {
      _isFilterVisible = value;
      if (_isFilterVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _search() {
    readWenkuHomeBloc(context).add(WenkuHomeEvent.searchWenku(
      query: _searchController.text,
      level: WenkuNovelLevel.indexByZhName(_levelController.optionName),
    ));
  }
}
