import 'dart:convert';

import 'package:chopper/chopper.dart';

class MultiTypeConverter implements Converter {
  const MultiTypeConverter();

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    var body = response.body;
    return response.copyWith<BodyType>(body: body);
  }

  @override
  Request convertRequest(Request request) => encodeJson(
        applyHeader(
          request,
          contentTypeKey,
          jsonHeaders,
          override: false,
        ),
      );

  Request encodeJson(Request request) {
    final String? contentType = request.headers[contentTypeKey];
    if ((contentType?.contains(jsonHeaders) ?? false) &&
        (request.body.runtimeType != String)) {
      return request.copyWith(body: jsonEncode(request.body));
    }
    return request;
  }
}
