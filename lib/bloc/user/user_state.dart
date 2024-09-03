part of 'user_cubit.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial({
    String? token,
    @Default('') String emailOrUsername,
    @Default('') String password,
    String? email,
    String? id,
    String? username,
    String? role,
    int? createAt,
    @Default(false) bool autoSignIn,
    DateTime? signInTime,
  }) = _Initial;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}
