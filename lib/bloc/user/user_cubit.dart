import 'package:auto_novel_reader_flutter/network/api_client.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
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
    String emailOrUsername,
    String password, {
    bool autoSignIn = true,
  }) async {
    final signInResponse = await apiClient.authService.postSignIn({
      'emailOrUsername': emailOrUsername,
      'password': password,
    });
    if (signInResponse.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return false;
    }
    if (signInResponse.statusCode != 200) {
      showErrorToast('登录失败, ${signInResponse.statusCode}');
      return false;
    }
    final token = signInResponse.body;
    return afterLogin(
        token: token, emailOrUsername: emailOrUsername, password: password);
  }

  Future<bool> signUp({
    required String email,
    required String username,
    required String password,
    required String emailCode,
  }) async {
    final response = await apiClient.authService.postSignUp({
      'email': email,
      'username': username,
      'password': password,
      'emailCode': emailCode,
    });
    if (response.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return false;
    }
    if (response.statusCode != 200) {
      showErrorToast('注册失败, ${response.statusCode}');
      return false;
    }
    return afterLogin(
      token: response.body,
      emailOrUsername: email,
      password: password,
    );
  }

  bool afterLogin({
    required String? token,
    required String emailOrUsername,
    required String password,
  }) {
    if (token == null || token.isEmpty) {
      showErrorToast('登录失败, 令牌为空');
      return false;
    }
    try {
      final jwt = JWT.decode(token).payload;
      emit(state.copyWith(
        id: jwt['id'],
        email: jwt['email'],
        username: jwt['username'],
        role: jwt['role'],
        createAt: jwt['createAt'],
        emailOrUsername: emailOrUsername,
        password: password,
        autoSignIn: true,
        token: token,
        signInTime: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      return false;
    }
    favoredCubit.init();
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
    } else if (signInTime.difference(DateTime.now()).inDays >= 25) {
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
    if (renewResponse?.statusCode == 502) {
      Fluttertoast.showToast(msg: '服务器维护中');
      return;
    }
    final token = renewResponse?.body;
    if (token == null || token.isEmpty) return;
    emit(state.copyWith(
      token: token,
      signInTime: DateTime.now(),
    ));
  }

  Future<void> signOut() async {
    emit(const UserState.initial());
    // TODO 清除缓存
  }

  bool get isSignIn => state.token != null;
  bool get isOldAss {
    final createAt = state.createAt;
    if (createAt == null) return false;
    final createTime = DateTime.fromMillisecondsSinceEpoch(createAt);
    return DateTime.now().difference(createTime).inDays >= 30;
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) => UserState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserState state) => state.toJson();
}
