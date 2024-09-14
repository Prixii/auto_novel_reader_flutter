import 'dart:ui';

import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/check_filter.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSearchWidget extends StatefulWidget {
  const WebSearchWidget({
    super.key,
    required this.searchController,
    required this.checkFilterController,
    required this.onSearch,
  });
  final TextEditingController searchController;
  final CheckFilterController<NovelProvider> checkFilterController;
  final Function onSearch;
  @override
  State<WebSearchWidget> createState() => _WebSearchWidgetState();
}

class _WebSearchWidgetState extends State<WebSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late CurvedAnimation _curvedScaleAnimation;
  late CurvedAnimation _curvedFadeAnimation;

  late bool isOldAss;

  bool _isFilterVisible = false;
  // bool _isHistoryVisible = false;
  // TODO 历史搜索

  @override
  void initState() {
    super.initState();
    isOldAss = readUserCubit(context).isOldAss;
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _curvedScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc, // 选择曲线
    );

    _curvedFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc, // 选择曲线
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
    return Stack(
      children: [
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
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: styleManager.colorScheme(context).secondaryContainer, // 设置底色
        borderRadius: BorderRadius.circular(24), // 圆角
      ),
      child: TextField(
        controller: widget.searchController,
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
          widget.onSearch.call();
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
    return SizeTransition(
      sizeFactor: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: double.infinity,
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
    );
  }

  Widget _buildFilters() {
    return BlocSelector<WebHomeBloc, WebHomeState, WebSearchData>(
      selector: (state) {
        return state.webSearchData;
      },
      builder: (context, searchData) {
        const providers = NovelProvider.values;
        const statusList = NovelStatus.values;
        const levels = WebNovelLevel.values;
        const translations = WebTranslationSource.values;
        const order = WebNovelOrder.values;
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckFilter<NovelProvider>(
                  title: '来源',
                  controller: widget.checkFilterController,
                  optionsValue: providers,
                  options: providers.map((e) => e.zhName).toList()),
              const SizedBox(height: 16.0),
              RadioFilter(
                title: '类型',
                values: statusList,
                options: statusList.map((e) => e.zhName).toList(),
                selectedOption: searchData.type.zhName,
                onChanged: (index) {
                  readWebHomeBloc(context)
                      .add(WebHomeEvent.setSearchData(searchData.copyWith(
                    type: statusList[index],
                  )));
                },
              ),
              ...(isOldAss
                  ? [
                      const SizedBox(height: 16.0),
                      RadioFilter(
                          title: '分级',
                          values: levels,
                          options: levels.map((e) => e.zhName).toList(),
                          selectedOption: searchData.level.zhName,
                          onChanged: (index) {
                            readWebHomeBloc(context).add(
                                WebHomeEvent.setSearchData(searchData.copyWith(
                              level: levels[index],
                            )));
                          }),
                    ]
                  : []),
              const SizedBox(height: 16.0),
              RadioFilter(
                title: '翻译',
                values: translations,
                options: translations.map((e) => e.zhName).toList(),
                selectedOption: searchData.translate.zhName,
                onChanged: (index) {
                  readWebHomeBloc(context)
                      .add(WebHomeEvent.setSearchData(searchData.copyWith(
                    translate: translations[index],
                  )));
                },
              ),
              const SizedBox(height: 16.0),
              RadioFilter(
                title: '排序',
                values: WebNovelOrder.values,
                options: order.map((e) => e.zhName).toList(),
                selectedOption: searchData.sort.zhName,
                onChanged: (index) {
                  readWebHomeBloc(context)
                      .add(WebHomeEvent.setSearchData(searchData.copyWith(
                    sort: order[index],
                  )));
                },
              ),
            ]);
      },
    );
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
