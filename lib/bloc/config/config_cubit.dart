import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:flutter/material.dart';
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
  setPreloadNovel(bool value) => emit(state.copyWith(preloadNovel: value));
  setThemeMode(ThemeMode value) {
    emit(state.copyWith(themeMode: value));
    styleManager.setTheme(styleManager.lightTheme);
  }

  setWebNovelConfig(WebNovelConfig value) =>
      emit(state.copyWith(webNovelConfig: value));

  setHost(String value) {
    if (value == state.host) return;
    emit(state.copyWith(host: value));
    apiClient.createChopper();
  }

  @override
  ConfigState? fromJson(Map<String, dynamic> json) =>
      ConfigState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ConfigState state) => state.toJson();
}
