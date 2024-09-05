import 'package:auto_novel_reader_flutter/ui/components/settings/user_info_tile.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/data_settings.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/download.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/preference_settings.dart';
import 'package:auto_novel_reader_flutter/ui/view/settings/read_settings.dart';
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
        IconOption(
            icon: UniconsLine.cog,
            text: '偏好设置',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PreferenceSettings()))),
        IconOption(
            icon: UniconsLine.book_alt,
            text: '阅读设置',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ReadSettings()))),
        IconOption(
            icon: UniconsLine.download_alt,
            text: '下载管理',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DownloadPage()))),
        IconOption(
            icon: UniconsLine.database,
            text: '数据管理',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DataSettings()))),
        _buildDivider(theme),
        const IconOption(
          icon: UniconsLine.question_circle,
          text: '关于',
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
}
