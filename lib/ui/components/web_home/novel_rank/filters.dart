import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/line_button.dart';
import 'package:auto_novel_reader_flutter/ui/components/web_home/web_novel/radio_filter.dart';
import 'package:flutter/widgets.dart';

// TODO 更新条件

class SyosetuComprehensiveFilter extends StatelessWidget {
  const SyosetuComprehensiveFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RadioFilter(
          title: '范围',
          options: SyosetuNovelPeriod.values.map((e) => e.zhName).toList(),
          values: SyosetuNovelPeriod.values,
          controller: RadioFilterController()),
      const SizedBox(height: 12),
      RadioFilter(
          title: '状态',
          options: NovelCategory.values.map((e) => e.zhName).toList(),
          values: NovelCategory.values,
          controller: RadioFilterController()),
      Expanded(child: Container()),
      LineButton(onPressed: () => {}, text: '搜索')
    ]);
  }
}

class SyosetuGenreFilter extends StatelessWidget {
  const SyosetuGenreFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioFilter(
            title: '流派',
            options: SyosetuGenre.values.map((e) => e.zhName).toList(),
            values: SyosetuGenre.values,
            controller: RadioFilterController()),
        const SizedBox(height: 12),
        RadioFilter(
            title: '范围',
            options: SyosetuNovelPeriod.values.map((e) => e.zhName).toList(),
            values: SyosetuNovelPeriod.values,
            controller: RadioFilterController()),
        const SizedBox(height: 12),
        RadioFilter(
            title: '状态',
            options: NovelCategory.values.map((e) => e.zhName).toList(),
            values: NovelCategory.values,
            controller: RadioFilterController()),
        Expanded(child: Container()),
        LineButton(onPressed: () => {}, text: '搜索')
      ],
    );
  }
}

class SyosetuIsekaiFilter extends StatelessWidget {
  const SyosetuIsekaiFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioFilter(
            title: '流派',
            options: SyosetuIsekaiGenre.values.map((e) => e.zhName).toList(),
            values: SyosetuIsekaiGenre.values,
            controller: RadioFilterController()),
        const SizedBox(height: 12),
        RadioFilter(
            title: '范围',
            options: SyosetuNovelPeriod.values.map((e) => e.zhName).toList(),
            values: SyosetuNovelPeriod.values,
            controller: RadioFilterController()),
        const SizedBox(height: 12),
        RadioFilter(
            title: '状态',
            options: NovelCategory.values.map((e) => e.zhName).toList(),
            values: NovelCategory.values,
            controller: RadioFilterController()),
        Expanded(child: Container()),
        LineButton(onPressed: () => {}, text: '搜索')
      ],
    );
  }
}

class KakuyomuGenreFilters extends StatelessWidget {
  const KakuyomuGenreFilters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RadioFilter(
          title: '流派',
          options: KakuyomuGenre.values.map((e) => e.zhName).toList(),
          values: KakuyomuGenre.values,
          controller: RadioFilterController()),
      const SizedBox(height: 12),
      RadioFilter(
          title: '状态',
          options: NovelCategory.values.map((e) => e.zhName).toList(),
          values: NovelCategory.values,
          controller: RadioFilterController()),
      Expanded(child: Container()),
      LineButton(onPressed: () => {}, text: '搜索')
    ]);
  }
}
