import 'dart:async';
import 'dart:math';

import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
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
    if (response.statusCode == 502) {
      errorLogger.logError(e, StackTrace.current,
          extra: '${response.statusCode}:${response.error}');
      return response;
    } else {
      errorLogger.logError(e, StackTrace.current,
          extra: '${response.statusCode}:${response.error}');
      showErrorToast('${response.statusCode}, ${response.error}');
      return response;
      // throw Exception([response.statusCode, response.error]);
    }
  }
}
