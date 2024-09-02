part of 'global_bloc.dart';

@freezed
class GlobalEvent with _$GlobalEvent {
  /// [isRememberMeChecked] 用户是否点击了自动登录功能
  /// [isAutoLogin] 这次登录是用户手动触发的，还是自动登录
  const factory GlobalEvent.switchNavigationDestination({
    @Default(1) int destinationIndex,
  }) = _SwitchNavigationDestination;
  const factory GlobalEvent.startProgress(ProgressType type, String message) =
      _StartProgress;
  const factory GlobalEvent.updateProgress(
      ProgressType type, int progress, String message) = _UpdateProgress;
  const factory GlobalEvent.endProgress(ProgressType type) = _EndProgress;
  const factory GlobalEvent.setReadType(ReadType readType) = _SetReadType;
}
