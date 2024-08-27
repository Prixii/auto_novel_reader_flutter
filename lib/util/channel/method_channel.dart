import 'package:flutter/services.dart';

const methodChannel = MethodChannel('auto_novel_reader_flutter/method_channel');

Future<void> handleSetVolumeShift(bool enable) async {
  return enable
      ? await methodChannel.invokeMethod('enableVolumeKeyShift')
      : await methodChannel.invokeMethod('disableVolumeKeyShift');
}
