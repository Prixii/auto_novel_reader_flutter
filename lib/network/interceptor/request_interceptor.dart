import 'dart:async';

import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';

class RequestInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    if (kDebugMode) {
      talker.info(
          '${chain.request.method} ${chain.request.url}\n${chain.request.body}');
    }
    if (userCubit.state.token == null) return chain.proceed(chain.request);

    final request = applyHeader(
      chain.request,
      'Authorization',
      'Bearer ${userCubit.state.token}',
    );
    return chain.proceed(request);
  }
}
