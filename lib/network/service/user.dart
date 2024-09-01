part of 'service.dart';

@ChopperApi(baseUrl: '/user')
abstract class UserService extends ChopperService {
  @Get(path: '')
  Future<Response> getUser();

  @Get(path: '/favored')
  Future<Response> getFavored();

  static UserService create([ChopperClient? client]) => _$UserService(client);
}
