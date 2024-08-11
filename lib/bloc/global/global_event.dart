part of 'global_bloc.dart';

@freezed
class GlobalEvent with _$GlobalEvent {
  /// [isRememberMeChecked] 用户是否点击了自动登录功能
  /// [isAutoLogin] 这次登录是用户手动触发的，还是自动登录
  const factory GlobalEvent.login({
    required String phone,
    required String password,
    required bool isRememberMeChecked,
    @Default(false) bool isAutoLogin,
  }) = _Login;

  const factory GlobalEvent.logout() = _Logout;

  const factory GlobalEvent.register({
    required String phone,
    required String password,
  }) = _Register;

  const factory GlobalEvent.switchNavigationDestination({
    @Default(1) int destinationIndex,
  }) = _SwitchNavigationDestination;

  const factory GlobalEvent.initConfig() = _InitConfig;

  const factory GlobalEvent.getUserInfo() = _GetUserInfo;
}
