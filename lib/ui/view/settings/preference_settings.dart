import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/tab_option.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/shield_settings.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PreferenceSettings extends StatelessWidget {
  const PreferenceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme(context).shadow,
        backgroundColor: styleManager.colorScheme(context).secondaryContainer,
        title: const Text('偏好设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelloPageSetter(context),
            _buildUrlSetter(context),
            _buildThemeSetter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHelloPageSetter(BuildContext context) {
    final cubit = readConfigCubit(context);
    return TabOption(
        initValue: cubit.state.helloPageIndex,
        label: '欢迎页',
        onTap: (value, index) => cubit.setHelloPage(index),
        icon: UniconsLine.laughing,
        tabs: const [
          '绿站',
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

  Widget _buildThemeSetter(BuildContext context) {
    final themeModeZhName = ThemeMode.values.map((e) => e.zhName).toList();
    final cubit = readConfigCubit(context);
    return TabOption(
        initValue: ThemeMode.values.indexOf(cubit.state.themeMode),
        label: '颜色模式',
        onTap: (value, index) => cubit.setThemeMode(ThemeMode.values[index]),
        icon: UniconsLine.paint_tool,
        tip: '需要重启才能生效',
        tabs: themeModeZhName);
  }

  // 当前 api 暂不支持
  Widget _buildShieldSetter(BuildContext context) {
    return IconOption(
        icon: UniconsLine.ban,
        text: '屏蔽设置',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ShieldSettings())));
  }
}
