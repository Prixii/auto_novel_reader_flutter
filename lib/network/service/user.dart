part of 'service.dart';

@ChopperApi(baseUrl: '/user')
abstract class UserService extends ChopperService {
  @Get(path: '')
  Future<Response> listUser();

  @Get(path: '/favored')
  Future<Response> favored();

  static UserService create([ChopperClient? client]) => _$UserService(client);
}
