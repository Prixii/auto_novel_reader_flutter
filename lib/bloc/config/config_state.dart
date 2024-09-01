part of 'config_cubit.dart';

@freezed
class ConfigState with _$ConfigState {
  const factory ConfigState.initial({
    @Default(false) bool slideShift, // 水平滑动翻页
    @Default(false) bool showErrorInfo, // 如果 html 元素加载失败，则显示错误信息
    @Default(true) bool volumeKeyShift, // 音量键控制翻页
  }) = _Initial;

  factory ConfigState.fromJson(Map<String, dynamic> json) =>
      _$ConfigStateFromJson(json);
}
