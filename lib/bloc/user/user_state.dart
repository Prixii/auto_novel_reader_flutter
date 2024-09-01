part of 'user_cubit.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial({
    @Default(null) String? token,
    @Default('') String emailOrUsername,
    @Default('') String password,
    @Default('') String nickname,
    @Default(false) bool autoLogin,
  }) = _Initial;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}
