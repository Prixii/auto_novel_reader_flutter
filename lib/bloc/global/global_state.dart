part of 'global_bloc.dart';

@freezed
class GlobalState with _$GlobalState {
  const factory GlobalState.initial({
    @Default(null) String? token,
    @Default(null) String? idCard,
    @Default(null) String? phone,
    @Default(null) String? name,
    @Default(1) int destinationIndex,
    @Default(false) bool isLogin,
    @Default(0) int progressValue,
    @Default('') String progressMessage,
    @Default(false) bool isLoading,
    @Default(null) int? progressTypeValue,
  }) = _Initial;
}
