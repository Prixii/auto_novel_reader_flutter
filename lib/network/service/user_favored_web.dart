part of 'service.dart';

@ChopperApi(baseUrl: '/user/favored-web')
abstract class UserFavoredWebService extends ChopperService {
  @Post(path: '')
  Future<Response> postWeb();

  @Put(path: '/{favoredId}')
  Future<Response> putId(
    @Path() String favoredId,
  );

  @Delete(path: '/{favoredId}')
  Future<Response> delId(@Path() String favoredId);

  Future<Response?> getIdList(
    String favoredId,
    int page,
    int pageSize,
    String sort,
  ) =>
      tokenRequest(() => _getIdList(favoredId, page, pageSize, sort));
  @Get(path: '/{favoredId}')
  Future<Response> _getIdList(
    @Path() String favoredId,
    @Query() int page,
    @Query() int pageSize,
    @Query() String sort,
  );

  @Put(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> putNovelId(@Path() String favoredId,
      @Path() String providerId, @Path() String novelId);

  @Delete(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> deleteNovelId(@Path() String favoredId,
      @Path() String providerId, @Path() String novelId);
  static UserFavoredWebService create([ChopperClient? client]) =>
      _$UserFavoredWebService(client);
}
