part of 'service.dart';

@ChopperApi(baseUrl: '/user/read-history-web')
abstract class UserReadHistoryWebService extends ChopperService {
  @Get(path: '')
  Future<Response> getList();

  @Delete(path: '')
  Future<Response> delHistory();

  @Get(path: '/paused')
  Future<Response> getPaused();

  @Put(path: '/paused')
  Future<Response> putPaused();

  @Delete(path: '/paused')
  Future<Response> delPaused();

  @Put(path: '/{providerId}/{novelId}')
  Future<Response> putNovelId(
      @Path() String providerId, @Path() String novelId);

  @Delete(path: '/{providerId}/{novelId}')
  Future<Response> delNovelId(
      @Path() String providerId, @Path() String novelId);
  static UserReadHistoryWebService create([ChopperClient? client]) =>
      _$UserReadHistoryWebService(client);
}
