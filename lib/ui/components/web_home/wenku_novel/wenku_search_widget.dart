import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/wenku_home/wenku_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WenkuSearchWidget extends StatefulWidget {
  const WenkuSearchWidget({
    super.key,
    required this.searchController,
    required this.onSearch,
  });
  final TextEditingController searchController;
  final Function onSearch;
  @override
  State<WenkuSearchWidget> createState() => _WenkuSearchWidgetState();
}

class _WenkuSearchWidgetState extends State<WenkuSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late CurvedAnimation _curvedScaleAnimation;
  late CurvedAnimation _curvedFadeAnimation;

  bool _isFilterVisible = false;
  // bool _isHistoryVisible = false;
  // TODO 历史搜索
  @override
  void initState() {
    super.initState();

    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _curvedScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );

    _curvedFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );

    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_curvedScaleAnimation);
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
        color: styleManager.colorScheme(context).secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: '中/日文标题或作者',
          hintStyle: TextStyle(
              color: styleManager.colorScheme(context).secondaryFixedDim),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search,
              color: styleManager.colorScheme(context).secondaryFixedDim),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onTap: () => _toggleVisibility(true),
        maxLines: 1,
        onSubmitted: (_) {
          widget.onSearch.call();
          _toggleVisibility(false);
        },
        style: TextStyle(
            color: styleManager.colorScheme(context).onSecondaryContainer),
      ),
    );
  }

  Widget _buildAnimatedFilter() {
    return SizeTransition(
      sizeFactor: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(12.0),
          width: double.infinity,
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
    );
  }

  Column _buildFilters() {
    final isOldAss = readUserCubit(context).isOldAss;
    final levelList =
        isOldAss ? WenkuNovelLevel.values : WenkuNovelLevel.youngAss;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: double.infinity,
        child: BlocSelector<WenkuHomeBloc, WenkuHomeState, WenkuSearchData>(
          selector: (state) {
            return state.wenkuSearchData;
          },
          builder: (context, state) {
            return RadioFilter(
              selectedOption: state.level.zhName,
              title: '分级',
              values: levelList,
              options: levelList.map((e) => e.zhName).toList(),
              onChanged: (index) {
                readWenkuHomeBloc(context)
                    .add(WenkuHomeEvent.setSearchData(state.copyWith(
                  level: levelList[index],
                )));
              },
            );
          },
        ),
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
}
