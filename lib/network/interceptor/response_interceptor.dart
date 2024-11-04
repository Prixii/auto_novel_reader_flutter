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
    late final Response<BodyType> response;
    try {
      response = await chain.proceed(chain.request);
    } catch (e, stackTrace) {
      errorLogger.logError(e, stackTrace);
      rethrow;
    }
    kDebugMode
        ? talker.info(
            '${response.body}\n ${response.error}\nurl:${chain.request.url}')
        : {};
    if (response.isSuccessful) return response;
    if (response.statusCode ~/ 100 == 5) {
      errorLogger.logError(e, StackTrace.current,
          extra: '${response.statusCode}:${response.error}');
      throw ServerException('${response.error}');
    } else {
      errorLogger.logError(e, StackTrace.current,
          extra:
              '${response.statusCode}:${response.error}\nurl:${chain.request.url}');
      showErrorToast('${response.statusCode}, ${response.error}');
      return response;
    }
  }
}

class ServerException implements Exception {
  ServerException(this.message);
  final String message;
}
