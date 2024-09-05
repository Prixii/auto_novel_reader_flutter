part of 'service.dart';

@ChopperApi(baseUrl: '/user/favored-wenku')
abstract class UserFavoredWenkuService extends ChopperService {
  @Post(path: '')
  Future<Response> _postWenku();

  Future<Response?> postWenku() => tokenRequest(() => _postWenku());

  @Put(path: '/{favoredId}')
  Future<Response> _putId(@Path() String favoredId);

  Future<Response?> putId(@Path() String favoredId) =>
      tokenRequest(() => _putId(favoredId));

  @Delete(path: '/{favoredId}')
  Future<Response> _delId(@Path() String favoredId);

  Future<Response?> delId(@Path() String favoredId) =>
      tokenRequest(() => _delId(favoredId));

  @Get(path: '/{favoredId}')
  Future<Response> _getIdList(@Path() String favoredId, @Query() int page,
      @Query() int pageSize, @Query() String sort);

  Future<Response?> getIdList({
    String favoredId = 'default',
    int page = 0,
    int pageSize = 12,
    String sort = 'update',
  }) =>
      tokenRequest(() => _getIdList(
            favoredId,
            page,
            pageSize,
            sort,
          ));

  @Put(path: '/{favoredId}/{novelId}')
  Future<Response> _putNovelId(
      @Path() String favoredId, @Path() String novelId);

  Future<Response?> putNovelId(String favoredId, String novelId) =>
      tokenRequest(() => _putNovelId(favoredId, novelId));

  @Delete(path: '/{favoredId}/{novelId}')
  Future<Response> _delNovelId(
      @Path() String favoredId, @Path() String novelId);
  Future<Response?> delNovelId(String favoredId, String novelId) =>
      tokenRequest(() => _delNovelId(favoredId, novelId));

  static UserFavoredWenkuService create([ChopperClient? client]) =>
      _$UserFavoredWenkuService(client);
}
