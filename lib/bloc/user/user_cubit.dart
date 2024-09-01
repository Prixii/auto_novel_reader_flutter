import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'user_state.dart';
part 'user_cubit.freezed.dart';
part 'user_cubit.g.dart';

class UserCubit extends HydratedCubit<UserState> {
  UserCubit() : super(const UserState.initial());

  Future<bool> signIn(
    BuildContext context,
    String emailOrUsername,
    String password, {
    bool autoLogin = false,
  }) async {
    final signInResponse = await authService.signIn({
      'emailOrUsername': emailOrUsername,
      'password': password,
    });
    final token = signInResponse.body;
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: '登录失败, 用户名或密码错误',
          textColor: Theme.of(context).colorScheme.onErrorContainer,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        );
      }
      return false;
    }
    emit(state.copyWith(
      emailOrUsername: emailOrUsername,
      password: password,
      autoLogin: autoLogin,
      token: token,
    ));
    return true;
  }

  /// 在 api 初始化完成后调用
  Future<void> activateAuth() async {
    if (state.token == null) return;
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) => UserState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserState state) => state.toJson();
}
