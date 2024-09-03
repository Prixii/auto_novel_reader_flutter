import 'package:auto_novel_reader_flutter/ui/components/settings/user_info_tile.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/switch_option.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/tab_option.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  final dividerIndent = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        child: _buildOptions(theme, context),
      ),
    );
  }

  Widget _buildOptions(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),
        const UserInfoTile(),
        _buildDivider(theme),
        _buildHelloPageSetter(context),
        _buildUrlSetter(context),
        _buildDivider(theme),
        _buildSlideShiftOption(context),
        _buildShowErrorInfoOption(context),
        _buildVolumeKeyShiftOption(context),
        _buildDivider(theme),
        _buildInfoIcons(),
        _buildDivider(theme),
        IconOption(
          icon: UniconsLine.brush_alt,
          text: '清空缓存',
          onTap: () => _cleanCache(context),
        ),
      ],
    );
  }

  Divider _buildDivider(ThemeData theme) {
    return Divider(
      indent: dividerIndent,
      endIndent: dividerIndent,
      color: theme.dividerColor,
    );
  }

  Widget _buildInfoIcons() {
    return const Column(
      children: [
        IconOption(
          padding: EdgeInsets.fromLTRB(32, 10, 0, 10),
          icon: UniconsLine.info_circle,
          text: '版本信息',
        ),
        IconOption(
          padding: EdgeInsets.fromLTRB(32, 10, 0, 10),
          icon: UniconsLine.question_circle,
          text: '关于',
        ),
      ],
    );
  }

  Widget _buildHelloPageSetter(BuildContext context) {
    final cubit = readConfigCubit(context);
    return TabOption(
        initValue: cubit.state.helloPageIndex,
        label: '欢迎页',
        onTap: (value, index) => cubit.setHelloPage(index),
        icon: UniconsLine.estate,
        tabs: const [
          '首页',
          '阅读',
          '设置',
        ]);
  }

  Widget _buildUrlSetter(BuildContext context) {
    const urls = [
      'books.fishhawk.top',
      'books1.fishhawk.top',
      'books2.fishhawk.top',
    ];
    final cubit = readConfigCubit(context);
    return TabOption(
        initValue: urls.indexOf(cubit.state.host),
        label: '绿站 host',
        onTap: (value, index) => cubit.setHost(value),
        icon: UniconsLine.estate,
        tabs: urls);
  }

  Widget _buildSlideShiftOption(BuildContext context) {
    return SwitchOption(
      icon: UniconsLine.arrows_resize_h,
      label: '横向滑动切换章节',
      value: readConfigCubit(context).state.slideShift,
      onChanged: (value) => {
        readConfigCubit(context).setSlideShift(value),
      },
    );
  }

  Widget _buildShowErrorInfoOption(BuildContext context) {
    return SwitchOption(
      icon: UniconsLine.info_circle,
      label: 'epub 错误信息显示',
      value: readConfigCubit(context).state.showErrorInfo,
      onChanged: (value) => {
        readConfigCubit(context).setShowErrorInfo(value),
      },
    );
  }

  Widget _buildVolumeKeyShiftOption(BuildContext context) {
    return SwitchOption(
      icon: UniconsLine.arrows_resize_v,
      label: '音量键切换章节',
      value: readConfigCubit(context).state.volumeKeyShift,
      onChanged: (value) => {
        readConfigCubit(context).setVolumeKeyShift(value),
      },
    );
  }

  void _cleanCache(BuildContext context) {
    readLocalFileCubit(context).cleanEpubManageData();
  }
}
