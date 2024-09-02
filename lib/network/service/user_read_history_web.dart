part of 'service.dart';

@ChopperApi(baseUrl: '/user/read-history-web')
abstract class UserReadHistoryWebService extends ChopperService {
  @Get(path: '')
  Future<Response> _getList();
  Future<Response?> getList() => tokenRequest(() => _getList());

  @Delete(path: '')
  Future<Response> _delHistory();
  Future<Response?> delHistory() => tokenRequest(() => _delHistory());

  @Get(path: '/paused')
  Future<Response> _getPaused();
  Future<Response?> getPaused() => tokenRequest(() => _getPaused());

  @Put(path: '/paused')
  Future<Response> _putPaused();
  Future<Response?> putPaused() => tokenRequest(() => _putPaused());

  @Delete(path: '/paused')
  Future<Response> _delPaused();
  Future<Response?> delPaused() => tokenRequest(() => _delPaused());

  @Put(path: '/{providerId}/{novelId}')
  Future<Response> _putNovelId(
      @Path() String providerId, @Path() String novelId);
  Future<Response?> putNovelId(String providerId, String novelId) =>
      tokenRequest(() => _putNovelId(providerId, novelId));

  @Delete(path: '/{providerId}/{novelId}')
  Future<Response> _delNovelId(
      @Path() String providerId, @Path() String novelId);
  Future<Response?> delNovelId(String providerId, String novelId) =>
      tokenRequest(() => _delNovelId(providerId, novelId));

  static UserReadHistoryWebService create([ChopperClient? client]) =>
      _$UserReadHistoryWebService(client);
}
