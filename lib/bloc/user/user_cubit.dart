import 'package:auto_novel_reader_flutter/bloc/web_home/web_home_bloc.dart';
import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'user_state.dart';
part 'user_cubit.freezed.dart';
part 'user_cubit.g.dart';

class UserCubit extends HydratedCubit<UserState> {
  UserCubit() : super(const UserState.initial());

  Future<bool> signIn(
    String emailOrUsername,
    String password, {
    bool autoSignIn = false,
  }) async {
    final signInResponse = await apiClient.authService.postSignIn({
      'emailOrUsername': emailOrUsername,
      'password': password,
    });
    final token = signInResponse.body;
    if (token == null || token.isEmpty) {
      showErrorToast('登录失败, 用户名或密码错误');
      return false;
    }
    emit(state.copyWith(
      emailOrUsername: emailOrUsername,
      password: password,
      autoSignIn: autoSignIn,
      token: token,
      signInTime: DateTime.now(),
    ));
    webHomeBloc.add(const WebHomeEvent.refreshFavoredWeb());
    return true;
  }

  /// 在 apiClient 初始化完成后调用
  Future<void> activateAuth(BuildContext context) async {
    if (!state.autoSignIn) {
      emit(const UserState.initial());
      return;
    }
    if (state.token == null) return;
    final signInTime = state.signInTime;
    if (signInTime == null) {
      emit(state.copyWith(signInTime: DateTime.now()));
      return;
    }
    if (signInTime.difference(DateTime.now()).inDays >= 30) {
      await _autoSignIn(context);
    } else if (signInTime.difference(DateTime.now()).inDays >= 20) {
      await _renewToken();
    }
  }

  Future<void> _autoSignIn(BuildContext context) async {
    final signInSucceed = await signIn(
      state.emailOrUsername,
      state.password,
      autoSignIn: true,
    );
    if (signInSucceed) return;

    showErrorToast('自动登录失败, 请尝试手动登录');
    emit(const UserState.initial());
  }

  Future<void> _renewToken() async {
    if (state.token == null) return;

    final renewResponse = await apiClient.authService.getRenew();
    final token = renewResponse.body;
    if (token == null || token.isEmpty) return;
    emit(state.copyWith(
      token: token,
      signInTime: DateTime.now(),
    ));
  }

  Future<void> signOut() async {
    emit(const UserState.initial());
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) => UserState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserState state) => state.toJson();
}
