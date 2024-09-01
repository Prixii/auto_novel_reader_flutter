part of 'service.dart';

@ChopperApi(baseUrl: '/user/favored-wenku')
abstract class UserFavoredWenkuService extends ChopperService {
  @Post(path: '')
  Future<Response> postWenku();

  @Put(path: '/{favoredId}')
  Future<Response> putId(@Path() String favoredId);

  @Delete(path: '/{favoredId}')
  Future<Response> delId(@Path() String favoredId);

  @Get(path: '/{favoredId}')
  Future<Response> getIdList(@Path() String favoredId);

  @Put(path: '/{favoredId}/{novelId}')
  Future<Response> putNovelId(@Path() String favoredId, @Path() String novelId);

  @Delete(path: '/{favoredId}/{novelId}')
  Future<Response> delNovelId(@Path() String favoredId, @Path() String novelId);

  static UserFavoredWenkuService create([ChopperClient? client]) =>
      _$UserFavoredWenkuService(client);
}
