import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/service/app.dart';
import 'package:auto_novel_reader_flutter/util/channel/key_down_channel.dart';
import 'package:auto_novel_reader_flutter/util/channel/method_channel.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'global_bloc.freezed.dart';
part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(const _Initial()) {
    on<GlobalEvent>((event, emit) async {
      await event.map(
        checkUpdate: (event) async => await _onCheckUpdate(event, emit),
        closeReleaseDialog: (event) async => await _onCloseReleaseDialog(emit),
        switchNavigationDestination: (event) async =>
            await _onSwitchNavigationDestination(event, emit),
        startProgress: (event) async => await _onStartProgress(event, emit),
        updateProgress: (event) async => await _onUpdateProgress(event, emit),
        endProgress: (event) async => await _onEndProgress(event, emit),
        setReadType: (event) async => await _onSetReadType(event, emit),
      );
    });
  }

  _onCheckUpdate(_CheckUpdate event, Emitter<GlobalState> emit) async {
    late final PackageInfo packageInfo;
    late final ReleaseData? latestReleaseData;
    await Future.wait([
      PackageInfo.fromPlatform().then((value) => packageInfo = value),
      getLatestRelease().then((value) => latestReleaseData = value),
    ]);
    if (latestReleaseData == null) {
      showErrorToast('获取最新版本失败');
      return;
    }
    if (packageInfo.version == latestReleaseData!.tag) {
      showSucceedToast('已是最新版本');
      return;
    }
    emit(state.copyWith(
      shouldShowNewReleaseDialog: true,
      latestReleaseData: latestReleaseData,
    ));
  }

  _onCloseReleaseDialog(Emitter<GlobalState> emit) {
    emit(state.copyWith(shouldShowNewReleaseDialog: false));
  }

  _onSwitchNavigationDestination(
      _SwitchNavigationDestination event, Emitter<GlobalState> emit) {
    emit(state.copyWith(destinationIndex: event.destinationIndex));
  }

  _onStartProgress(_StartProgress event, Emitter<GlobalState> emit) async {
    if (state.progressTypeValue != null) return;
    emit(state.copyWith(
      progressTypeValue: event.type.value,
      progressValue: 0,
      progressMessage: event.message,
    ));
  }

  _onUpdateProgress(_UpdateProgress event, Emitter<GlobalState> emit) {
    if (state.progressTypeValue == null) return;
    if (event.type.value != state.progressTypeValue) return;
    emit(state.copyWith(
      progressMessage: event.message,
      progressValue: event.progress,
    ));
  }

  _onEndProgress(_EndProgress event, Emitter<GlobalState> emit) {
    if (state.progressTypeValue == null) return;
    if (event.type.value != state.progressTypeValue) return;
    emit(state.copyWith(
      progressTypeValue: null,
      progressValue: 0,
      progressMessage: '',
    ));
  }

  _onSetReadType(_SetReadType event, Emitter<GlobalState> emit) {
    if (configCubit.state.volumeKeyShift == false) return;
    if (event.readType == state.readType) return;

    if (event.readType == ReadType.none) {
      unsubscribeVolumeKeyEvent();
      handleSetVolumeShift(false);
    } else {
      handleSetVolumeShift(configCubit.state.volumeKeyShift);
      subscribeVolumeKeyEvent();
    }
    emit(state.copyWith(readType: event.readType));
  }
}
