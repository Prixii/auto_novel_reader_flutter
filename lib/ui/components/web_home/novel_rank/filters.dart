import 'package:auto_novel_reader_flutter/bloc/novel_rank/novel_rank_bloc.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    return BlocSelector<NovelRankBloc, NovelRankState,
        SyosetuComprehensiveSearchData>(
      selector: (state) {
        return state.syosetuComprehensiveSearchData;
      },
      builder: (context, searchData) {
        const rangeList = SyosetuNovelRange.values;
        const statusList = NovelStatus.values;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioFilter(
                title: '范围',
                selectedOption: searchData.range.zhName,
                options: rangeList.map((e) => e.zhName).toList(),
                values: rangeList,
                onChanged: (index) {
                  readNovelRankBloc(context).add(
                      NovelRankEvent.updateSyosetuComprehensiveSearchData(
                          searchData.copyWith(range: rangeList[index])));
                },
              ),
              const SizedBox(height: 12),
              RadioFilter(
                title: '状态',
                options: statusList.map((e) => e.zhName).toList(),
                values: statusList,
                selectedOption: searchData.status.zhName,
                onChanged: (index) {
                  readNovelRankBloc(context).add(
                      NovelRankEvent.updateSyosetuComprehensiveSearchData(
                          searchData.copyWith(status: statusList[index])));
                },
              ),
            ]);
      },
    );
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
  @override
  Widget build(BuildContext context) {
    return BlocSelector<NovelRankBloc, NovelRankState, SyosetuGenreSearchData>(
      selector: (state) {
        return state.syosetuGenreSearchData;
      },
      builder: (context, searchData) {
        const genres = SyosetuGenre.values;
        const ranges = SyosetuNovelRange.values;
        const statusList = NovelStatus.values;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioFilter(
              title: '流派',
              options: genres.map((e) => e.zhName).toList(),
              values: genres,
              selectedOption: searchData.genre.zhName,
              onChanged: (index) {
                readNovelRankBloc(context).add(
                    NovelRankEvent.updateSyosetuGenreSearchData(
                        searchData.copyWith(genre: genres[index])));
              },
            ),
            const SizedBox(height: 12),
            RadioFilter(
              title: '范围',
              options: ranges.map((e) => e.zhName).toList(),
              values: ranges,
              selectedOption: searchData.range.zhName,
              onChanged: (index) {
                readNovelRankBloc(context).add(
                    NovelRankEvent.updateSyosetuGenreSearchData(
                        searchData.copyWith(range: ranges[index])));
              },
            ),
            const SizedBox(height: 12),
            RadioFilter(
                title: '状态',
                options: statusList.map((e) => e.zhName).toList(),
                values: statusList,
                selectedOption: searchData.status.zhName,
                onChanged: (index) {
                  readNovelRankBloc(context).add(
                      NovelRankEvent.updateSyosetuGenreSearchData(
                          searchData.copyWith(status: statusList[index])));
                }),
          ],
        );
      },
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
  @override
  Widget build(BuildContext context) {
    return BlocSelector<NovelRankBloc, NovelRankState, SyosetuIsekaiSearchData>(
      selector: (state) {
        return state.syosetuIsekaiSearchData;
      },
      builder: (context, searchData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioFilter(
              title: '流派',
              options: SyosetuIsekaiGenre.values.map((e) => e.zhName).toList(),
              values: SyosetuIsekaiGenre.values,
              selectedOption: searchData.genre.zhName,
              onChanged: (index) {
                readNovelRankBloc(context).add(
                    NovelRankEvent.updateSyosetuIsekaiSearchData(searchData
                        .copyWith(genre: SyosetuIsekaiGenre.values[index])));
              },
            ),
            const SizedBox(height: 12),
            RadioFilter(
                title: '范围',
                options: SyosetuNovelRange.values.map((e) => e.zhName).toList(),
                values: SyosetuNovelRange.values,
                selectedOption: searchData.range.zhName,
                onChanged: (index) {
                  readNovelRankBloc(context).add(
                      NovelRankEvent.updateSyosetuIsekaiSearchData(searchData
                          .copyWith(range: SyosetuNovelRange.values[index])));
                }),
            const SizedBox(height: 12),
            RadioFilter(
              title: '状态',
              options: NovelStatus.values.map((e) => e.zhName).toList(),
              values: NovelStatus.values,
              selectedOption: searchData.status.zhName,
              onChanged: (index) {
                readNovelRankBloc(context).add(
                    NovelRankEvent.updateSyosetuIsekaiSearchData(searchData
                        .copyWith(status: NovelStatus.values[index])));
              },
            ),
          ],
        );
      },
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
  @override
  Widget build(BuildContext context) {
    return BlocSelector<NovelRankBloc, NovelRankState, KakuyomuGenreSearchData>(
      selector: (state) {
        return state.kakuyomuGenreSearchData;
      },
      builder: (context, searchData) {
        const genres = KakuyomuGenre.values;
        const ranges = NovelRange.values;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioFilter<KakuyomuGenre>(
                title: '流派',
                options: genres.map((e) => e.zhName).toList(),
                values: genres,
                selectedOption: searchData.genre.zhName,
                onChanged: (index) {
                  readNovelRankBloc(context).add(
                      NovelRankEvent.updateKakuyomuGenreSearchData(
                          searchData.copyWith(genre: genres[index])));
                },
              ),
              const SizedBox(height: 12),
              RadioFilter<NovelRange>(
                  title: '状态',
                  options: ranges.map((e) => e.zhName).toList(),
                  values: ranges,
                  selectedOption: searchData.range.zhName,
                  onChanged: (index) {
                    readNovelRankBloc(context).add(
                        NovelRankEvent.updateKakuyomuGenreSearchData(
                            searchData.copyWith(range: ranges[index])));
                  }),
            ]);
      },
    );
  }
}
