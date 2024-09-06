import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/switch_option.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ReadSettings extends StatelessWidget {
  const ReadSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: styleManager.colorScheme.shadow,
        backgroundColor: styleManager.colorScheme.secondaryContainer,
        title: const Text('阅读设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlideShiftOption(context),
            _buildShowErrorInfoOption(context),
            _buildVolumeKeyShiftOption(context),
          ],
        ),
      ),
    );
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
}