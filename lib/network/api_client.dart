import 'dart:io';

import 'package:auto_novel_reader_flutter/network/interceptor/response_interceptor.dart';
import 'package:auto_novel_reader_flutter/network/interceptor/request_interceptor.dart';
import 'package:auto_novel_reader_flutter/network/service/service.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:chopper/chopper.dart';

import 'package:http/io_client.dart' as http;

typedef JsonBody = Map<String, dynamic>;

final apiClient = _ApiClient();

class _ApiClient {
  ChopperClient? chopper;
  late ArticleService articleService;
  late AuthService authService;
  late CommentService commentService;
  late OperationHistoryService operationHistoryService;
  late SakuraService sakuraService;
  late UserFavoredWebService userFavoredWebService;
  late UserFavoredWenkuService userFavoredWenkuService;
  late UserReadHistoryWebService userReadHistoryWebService;
  late UserService userService;
  late WebNovelService webNovelService;
  late WenkuNovelService wenkuNovelService;

  final _tokenInterceptor = RequestInterceptor();
  final _responseInterceptor = ResponseInterceptor();

  void createChopper() {
    chopper = ChopperClient(
      client: http.IOClient(
        HttpClient()..connectionTimeout = const Duration(seconds: 5),
      ),
      baseUrl: Uri.parse('https://${configCubit.state.host}/api'),
      interceptors: [
        _tokenInterceptor,
        _responseInterceptor,
      ],
      services: [
        ArticleService.create(),
        AuthService.create(),
        CommentService.create(),
        OperationHistoryService.create(),
        SakuraService.create(),
        UserFavoredWebService.create(),
        UserFavoredWenkuService.create(),
        UserReadHistoryWebService.create(),
        UserService.create(),
        WebNovelService.create(),
        WenkuNovelService.create(),
      ],
      converter: const JsonConverter(),
    );

    articleService = chopper!.getService<ArticleService>();
    authService = chopper!.getService<AuthService>();
    commentService = chopper!.getService<CommentService>();
    operationHistoryService = chopper!.getService<OperationHistoryService>();
    sakuraService = chopper!.getService<SakuraService>();
    userFavoredWebService = chopper!.getService<UserFavoredWebService>();
    userFavoredWenkuService = chopper!.getService<UserFavoredWenkuService>();
    userReadHistoryWebService =
        chopper!.getService<UserReadHistoryWebService>();
    userService = chopper!.getService<UserService>();
    webNovelService = chopper!.getService<WebNovelService>();
    wenkuNovelService = chopper!.getService<WenkuNovelService>();
  }
}

///对于需要 token 的 api,需要在外层封装一层该函数
Future<Response?> tokenRequest<T>(
  Future<Response<T?>> Function() body,
) async {
  final token = userCubit.state.token;
  if (token == null) return null;
  return await body.call();
}
