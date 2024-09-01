part of 'service.dart';

@ChopperApi(baseUrl: '/sakura')
abstract class SakuraService extends ChopperService {
  @Post(path: '/incorrect-case')
  Future<Response> postIncorrectCase();

  static SakuraService create([ChopperClient? client]) =>
      _$SakuraService(client);
}
