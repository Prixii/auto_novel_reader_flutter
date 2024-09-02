part of 'service.dart';

@ChopperApi(baseUrl: '/user')
abstract class UserService extends ChopperService {
  @Get(path: '')
  Future<Response> _getUser();
  Future<Response?> getUser() => tokenRequest(() => _getUser());

  @Get(path: '/favored')
  Future<Response> _getFavored();
  Future<Response?> getFavored() => tokenRequest(() => _getFavored());

  static UserService create([ChopperClient? client]) => _$UserService(client);
}
