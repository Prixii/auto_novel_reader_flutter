part of 'global_bloc.dart';

@freezed
class GlobalEvent with _$GlobalEvent {
  const factory GlobalEvent.checkUpdate(
      {@Default(false) bool showSuccessToast}) = _CheckUpdate;
  const factory GlobalEvent.closeReleaseDialog() = _CloseReleaseDialog;
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
