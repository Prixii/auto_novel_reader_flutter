import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/request_interceptor.dart';
import 'package:auto_novel_reader_flutter/network/service/service.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:chopper/chopper.dart';

ChopperClient? chopper;
late AuthService authService;
final _tokenInterceptor = RequestInterceptor();
final _responseInterceptor = ResponseInterceptor();

void createChopper() {
  chopper = ChopperClient(
    baseUrl: Uri.parse('https://${configCubit.state.url}/api'),
    interceptors: [
      _tokenInterceptor,
      _responseInterceptor,
    ],
    services: [
      AuthService.create(),
    ],
    converter: const JsonConverter(),
  );

  authService = chopper!.getService<AuthService>();
}
