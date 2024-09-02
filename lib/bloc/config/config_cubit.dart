import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'config_state.dart';
part 'config_cubit.freezed.dart';
part 'config_cubit.g.dart';

class ConfigCubit extends HydratedCubit<ConfigState> {
  ConfigCubit() : super(const ConfigState.initial());

  setSlideShift(bool value) => emit(state.copyWith(slideShift: value));

  setShowErrorInfo(bool value) => emit(state.copyWith(showErrorInfo: value));

  setHelloPage(int value) => emit(state.copyWith(helloPageIndex: value));

  setVolumeKeyShift(bool value) => emit(state.copyWith(volumeKeyShift: value));

  setUrl(String value) {
    if (value == state.url) return;
    emit(state.copyWith(url: value));
    apiClient.createChopper();
  }

  @override
  ConfigState? fromJson(Map<String, dynamic> json) =>
      ConfigState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ConfigState state) => state.toJson();
}
