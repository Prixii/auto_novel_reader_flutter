import 'dart:async';

import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';

class ResponseInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final response = await chain.proceed(chain.request);
    if (kDebugMode) {
      talker.info('${response.body}\n ${response.error}');
    }
    if (response.isSuccessful) return response;
    talker.error(response.error);
    throw Exception(response.error);
  }
}
