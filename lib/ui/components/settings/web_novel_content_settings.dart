import 'package:auto_novel_reader_flutter/bloc/config/config_cubit.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/switch_option.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/tab_option.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicons/unicons.dart';

class WebNovelContentSettings extends StatelessWidget {
  const WebNovelContentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConfigCubit, ConfigState, WebNovelConfig>(
      selector: (state) {
        return state.webNovelConfig;
      },
      builder: (context, config) {
        const languages = Language.values;
        var translationSourcesOrder = [...config.translationSourcesOrder];
        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              _buildLanguageSelector(languages, config, context),
              _buildTranslationSourceSelector(config, context),
              _buildTrimSetter(config, context),
              _buildShowTranslationSourceSetter(config, context),
              const SizedBox(height: 8),
              _buildTranslationOrderTitle(context),
              const SizedBox(height: 8),
              _buildTranslationOrderSetter(
                  translationSourcesOrder, context, config),
            ],
          ),
        );
      },
    );
  }

  SwitchOption _buildShowTranslationSourceSetter(
      WebNovelConfig config, BuildContext context) {
    return SwitchOption(
      icon: UniconsLine.robot,
      label: '显示翻译来源',
      value: config.showTranslationSource,
      onChanged: (value) => {
        readConfigCubit(context)
            .setWebNovelConfig(config.copyWith(showTranslationSource: value))
      },
    );
  }

  SwitchOption _buildTrimSetter(WebNovelConfig config, BuildContext context) {
    return SwitchOption(
      icon: UniconsLine.arrows_merge,
      label: '去除缩进',
      value: config.enableTrim,
      onChanged: (value) => {
        readConfigCubit(context)
            .setWebNovelConfig(config.copyWith(enableTrim: value))
      },
    );
  }

  Padding _buildTranslationOrderTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          Text(
            '翻译顺序',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '长按调整顺序, 双击设置启用状态',
            style: styleManager.tipText,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationOrderSetter(
      List<TranslationSource> translationSourcesOrder,
      BuildContext context,
      WebNovelConfig config) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _buildOptions(translationSourcesOrder, context, config),
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        var child = translationSourcesOrder.removeAt(oldIndex);
        translationSourcesOrder.insert(newIndex, child);
        readConfigCubit(context).setWebNovelConfig(config.copyWith(
          translationSourcesOrder: translationSourcesOrder,
        ));
      },
    );
  }

  List<Widget> _buildOptions(List<TranslationSource> translationSourcesOrder,
      BuildContext context, WebNovelConfig config) {
    var options = <Widget>[];
    for (var i = 0; i < translationSourcesOrder.length; i++) {
      final item = translationSourcesOrder[i];
      final widget = Padding(
        padding: const EdgeInsets.only(right: 30, left: 20),
        key: ValueKey(item),
        child: InkWell(
          onDoubleTap: () {
            final newEnabledMap = {...config.translationSourcesEnabled};
            newEnabledMap[item] = !newEnabledMap[item]!;
            readConfigCubit(context).setWebNovelConfig(config.copyWith(
              translationSourcesEnabled: newEnabledMap,
            ));
          },
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: config.translationSourcesEnabled[item]!
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).disabledColor,
              borderRadius: BorderRadius.only(
                topLeft: i == 0 ? const Radius.circular(10) : Radius.zero,
                topRight: i == 0 ? const Radius.circular(10) : Radius.zero,
                bottomLeft: i == translationSourcesOrder.length - 1
                    ? const Radius.circular(10)
                    : Radius.zero,
                bottomRight: i == translationSourcesOrder.length - 1
                    ? const Radius.circular(10)
                    : Radius.zero,
              ),
            ),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(item.zhName),
          ),
        ),
      );
      options.add(widget);
    }
    return options;
  }

  Widget _buildTranslationSourceSelector(
      WebNovelConfig config, BuildContext context) {
    return TabOption(
        icon: UniconsLine.english_to_chinese,
        label: '翻译',
        initValue: TranslationMode.values.indexOf(config.translationMode),
        onTap: (_, index) => {
              readConfigCubit(context).setWebNovelConfig(config.copyWith(
                translationMode: TranslationMode.values[index],
              ))
            },
        tabs: TranslationMode.values.map((e) => e.zhName).toList());
  }

  Widget _buildLanguageSelector(
      List<Language> languages, WebNovelConfig config, BuildContext context) {
    return TabOption(
        icon: UniconsLine.letter_chinese_a,
        label: '语言',
        initValue: languages.indexOf(config.language),
        onTap: (_, index) => {
              readConfigCubit(context).setWebNovelConfig(config.copyWith(
                language: languages[index],
              ))
            },
        tabs: languages.map((e) => e.zhName).toList());
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          UniconsLine.book,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Web 阅读内容设置',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
