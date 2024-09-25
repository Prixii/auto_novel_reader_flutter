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

class NovelAppearanceSettings extends StatelessWidget {
  const NovelAppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConfigCubit, ConfigState, NovelAppearanceConfig>(
        selector: (state) {
      return state.novelAppearanceConfig;
    }, builder: (context, config) {
      return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              _buildRenderModeSelector(config, context),
              _buildFontSizeSetter(context, config),
              SwitchOption(
                  icon: UniconsLine.bold,
                  label: '字体加粗',
                  value: config.boldFont,
                  onChanged: (value) => readConfigCubit(context)
                      .setNovelAppearanceConfig(
                          config.copyWith(boldFont: value))),
              SizedBox(
                height: 48,
                child: Center(
                    child: Text(
                  '预览',
                  style: TextStyle(
                    fontSize: config.fontSize.toDouble(),
                    fontWeight:
                        config.boldFont ? FontWeight.bold : FontWeight.normal,
                  ),
                )),
              ),
            ],
          ));
    });
  }

  // TODO 脏位, 清除分页数据
  Widget _buildFontSizeSetter(
      BuildContext context, NovelAppearanceConfig config) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Icon(
          UniconsLine.text_size,
          color: styleManager.colorScheme(context).onSecondaryContainer,
        ),
        const SizedBox(width: 10),
        Text(
          '字体大小',
          style: styleManager.textTheme(context).bodyLarge,
        ),
        Expanded(
          child: Slider(
            value: config.fontSize.toDouble(),
            min: 8.0,
            max: 30.0,
            divisions: 22,
            label: config.fontSize.toDouble().toStringAsFixed(0),
            onChanged: (double value) => readConfigCubit(context)
                .setNovelAppearanceConfig(
                    config.copyWith(fontSize: value.toInt())),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          UniconsLine.book,
          color: styleManager.colorScheme(context).onSecondaryContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Web 显示样式设置',
            style: styleManager.textTheme(context).titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildRenderModeSelector(
      NovelAppearanceConfig config, BuildContext context) {
    const renderType = NovelRenderType.values;
    return TabOption(
        icon: UniconsLine.file_download_alt,
        label: '渲染模式',
        initValue: renderType.indexOf(config.renderType),
        onTap: (_, index) => {
              readConfigCubit(context).setNovelAppearanceConfig(config.copyWith(
                renderType: renderType[index],
                horizontalMargin: 40,
                verticalMargin: 80,
              ))
            },
        tabs: renderType.map((e) => e.zhName).toList());
  }
}
