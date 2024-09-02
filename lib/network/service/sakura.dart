part of 'service.dart';

@ChopperApi(baseUrl: '/sakura')
abstract class SakuraService extends ChopperService {
  @Post(path: '/incorrect-case')
  Future<Response> _postIncorrectCase();
  Future<Response?> postIncorrectCase() =>
      tokenRequest(() => _postIncorrectCase());

  static SakuraService create([ChopperClient? client]) =>
      _$SakuraService(client);
}
