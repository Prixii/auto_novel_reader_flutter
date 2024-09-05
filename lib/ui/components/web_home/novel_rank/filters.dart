import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/widgets.dart';

// TODO 更新条件

class SyosetuComprehensiveFilter extends StatefulWidget {
  const SyosetuComprehensiveFilter({
    super.key,
  });

  @override
  State<SyosetuComprehensiveFilter> createState() =>
      _SyosetuComprehensiveFilterState();
}

class _SyosetuComprehensiveFilterState
    extends State<SyosetuComprehensiveFilter> {
  final RadioFilterController _rangeController = RadioFilterController();

  final RadioFilterController _statusController = RadioFilterController();

  @override
  Widget build(BuildContext context) {
    final syosetuComprehensiveSearchData =
        readNovelRankBloc(context).state.syosetuComprehensiveSearchData;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioFilter(
              title: '范围',
              initOptionName: syosetuComprehensiveSearchData.range.zhName,
              initValue: syosetuComprehensiveSearchData.range,
              options: SyosetuNovelRange.values.map((e) => e.zhName).toList(),
              values: SyosetuNovelRange.values,
              controller: _rangeController),
          const SizedBox(height: 12),
          RadioFilter(
              title: '状态',
              initOptionName: syosetuComprehensiveSearchData.status.zhName,
              initValue: syosetuComprehensiveSearchData.status,
              options: NovelStatus.values.map((e) => e.zhName).toList(),
              values: NovelStatus.values,
              controller: _statusController),
          LineButton(
              onPressed: () {
                readNovelRankBloc(context).add(
                    NovelRankEvent.updateSyosetuComprehensiveSearchData(
                        _rangeController.optionValue,
                        _statusController.optionValue));
              },
              text: '搜索')
        ]);
  }
}

class SyosetuGenreFilter extends StatefulWidget {
  const SyosetuGenreFilter({
    super.key,
  });

  @override
  State<SyosetuGenreFilter> createState() => _SyosetuGenreFilterState();
}

class _SyosetuGenreFilterState extends State<SyosetuGenreFilter> {
  final RadioFilterController _genreController = RadioFilterController();

  final RadioFilterController _rangeController = RadioFilterController();

  final RadioFilterController _statusController = RadioFilterController();

  @override
  Widget build(BuildContext context) {
    final syosetuGenreSearchData =
        readNovelRankBloc(context).state.syosetuGenreSearchData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioFilter(
            title: '流派',
            initOptionName: syosetuGenreSearchData.genre.zhName,
            initValue: syosetuGenreSearchData.genre,
            options: SyosetuGenre.values.map((e) => e.zhName).toList(),
            values: SyosetuGenre.values,
            controller: _genreController),
        const SizedBox(height: 12),
        RadioFilter(
            title: '范围',
            initOptionName: syosetuGenreSearchData.range.zhName,
            initValue: syosetuGenreSearchData.range,
            options: SyosetuNovelRange.values.map((e) => e.zhName).toList(),
            values: SyosetuNovelRange.values,
            controller: _rangeController),
        const SizedBox(height: 12),
        RadioFilter(
            title: '状态',
            initOptionName: syosetuGenreSearchData.status.zhName,
            initValue: syosetuGenreSearchData.status,
            options: NovelStatus.values.map((e) => e.zhName).toList(),
            values: NovelStatus.values,
            controller: _statusController),
        LineButton(
            onPressed: () {
              readNovelRankBloc(context).add(
                NovelRankEvent.updateSyosetuGenreSearchData(
                    _genreController.optionValue,
                    _rangeController.optionValue,
                    _statusController.optionValue),
              );
            },
            text: '搜索')
      ],
    );
  }
}

class SyosetuIsekaiFilter extends StatefulWidget {
  const SyosetuIsekaiFilter({
    super.key,
  });

  @override
  State<SyosetuIsekaiFilter> createState() => _SyosetuIsekaiFilterState();
}

class _SyosetuIsekaiFilterState extends State<SyosetuIsekaiFilter> {
  final RadioFilterController _genreController = RadioFilterController();

  final RadioFilterController _rangeController = RadioFilterController();

  final RadioFilterController _statusController = RadioFilterController();

  @override
  Widget build(BuildContext context) {
    final syosetuIsekaiSearchData =
        readNovelRankBloc(context).state.syosetuIsekaiSearchData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioFilter(
            title: '流派',
            initOptionName: syosetuIsekaiSearchData.genre.zhName,
            initValue: syosetuIsekaiSearchData.genre,
            options: SyosetuIsekaiGenre.values.map((e) => e.zhName).toList(),
            values: SyosetuIsekaiGenre.values,
            controller: _genreController),
        const SizedBox(height: 12),
        RadioFilter(
            title: '范围',
            initOptionName: syosetuIsekaiSearchData.range.zhName,
            initValue: syosetuIsekaiSearchData.range,
            options: SyosetuNovelRange.values.map((e) => e.zhName).toList(),
            values: SyosetuNovelRange.values,
            controller: _rangeController),
        const SizedBox(height: 12),
        RadioFilter(
            title: '状态',
            initOptionName: syosetuIsekaiSearchData.status.zhName,
            initValue: syosetuIsekaiSearchData.status,
            options: NovelStatus.values.map((e) => e.zhName).toList(),
            values: NovelStatus.values,
            controller: _statusController),
        LineButton(
            onPressed: () {
              readNovelRankBloc(context).add(
                  NovelRankEvent.updateSyosetuIsekaiSearchData(
                      _genreController.optionValue,
                      _rangeController.optionValue,
                      _statusController.optionValue));
            },
            text: '搜索')
      ],
    );
  }
}

class KakuyomuGenreFilters extends StatefulWidget {
  const KakuyomuGenreFilters({
    super.key,
  });

  @override
  State<KakuyomuGenreFilters> createState() => _KakuyomuGenreFiltersState();
}

class _KakuyomuGenreFiltersState extends State<KakuyomuGenreFilters> {
  final RadioFilterController _genreController = RadioFilterController();

  final RadioFilterController _statusController = RadioFilterController();

  @override
  Widget build(BuildContext context) {
    final searchData = readNovelRankBloc(context).state.kakuyomuGenreSearchData;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioFilter<KakuyomuGenre>(
              title: '流派',
              initOptionName: searchData.genre.zhName,
              initValue: searchData.genre,
              options: KakuyomuGenre.values.map((e) => e.zhName).toList(),
              values: KakuyomuGenre.values,
              controller: _genreController),
          const SizedBox(height: 12),
          RadioFilter<NovelRange>(
              title: '状态',
              initOptionName: searchData.range.zhName,
              initValue: searchData.range,
              options: NovelRange.values.map((e) => e.zhName).toList(),
              values: NovelRange.values,
              controller: _statusController),
          LineButton(
              onPressed: () {
                readNovelRankBloc(context).add(
                  NovelRankEvent.updateKakuyomuGenreSearchData(
                      _genreController.optionValue,
                      _statusController.optionValue),
                );
              },
              text: '搜索')
        ]);
  }
}
