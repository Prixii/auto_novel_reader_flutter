import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'config_state.dart';
part 'config_cubit.freezed.dart';
part 'config_cubit.g.dart';

class ConfigCubit extends HydratedCubit<ConfigState> {
  ConfigCubit() : super(const ConfigState.initial());

  setSlideShift(bool value) => emit(state.copyWith(slideShift: value));

  setShowErrorInfo(bool value) => emit(state.copyWith(showErrorInfo: value));

  @override
  ConfigState? fromJson(Map<String, dynamic> json) =>
      ConfigState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ConfigState state) => state.toJson();
}
