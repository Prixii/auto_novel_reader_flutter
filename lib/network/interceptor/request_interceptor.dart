import 'dart:async';

import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';

class RequestInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final token = userCubit.state.token;
    if (token == null ||
        token.isEmpty ||
        tokenlessApi.contains(chain.request.url.toString())) {
      return chain.proceed(chain.request);
    }

    final request = applyHeader(
      chain.request,
      'Authorization',
      'Bearer $token',
    );

    kDebugMode
        ? talker.info(
            '${chain.request.method} ${chain.request.url}\nheader${chain.request.headers}\n${chain.request.body}')
        : {};
    return chain.proceed(request);
  }
}

final tokenlessApi = ['https://books.fishhawk.top/api/auth/sign-in'];
