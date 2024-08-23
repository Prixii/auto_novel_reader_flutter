part of 'config_cubit.dart';

@freezed
class ConfigState with _$ConfigState {
  const factory ConfigState.initial({
    @Default(false) bool slideShift,
  }) = _Initial;

  factory ConfigState.fromJson(Map<String, dynamic> json) =>
      _$ConfigStateFromJson(json);
}
