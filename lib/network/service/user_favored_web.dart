part of 'service.dart';

@ChopperApi(baseUrl: '/user/favored-web')
abstract class UserFavoredWebService extends ChopperService {
  @Post(path: '')
  Future<Response> postWeb();

  @Put(path: '/{favoredId}')
  Future<Response> putId(@Path() String favoredId);

  @Delete(path: '/{favoredId}')
  Future<Response> delId(@Path() String favoredId);

  @Get(path: '/{favoredId}')
  Future<Response> getIdList(@Path() String favoredId);

  @Put(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> putNovelId(@Path() String favoredId,
      @Path() String providerId, @Path() String novelId);

  @Delete(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> deleteNovelId(@Path() String favoredId,
      @Path() String providerId, @Path() String novelId);
  static UserFavoredWebService create([ChopperClient? client]) =>
      _$UserFavoredWebService(client);
}
