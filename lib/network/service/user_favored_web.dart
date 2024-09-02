part of 'service.dart';

@ChopperApi(baseUrl: '/user/favored-web')
abstract class UserFavoredWebService extends ChopperService {
  @Post(path: '')
  Future<Response> _postWeb();
  Future<Response?> postWeb() => tokenRequest(() => _postWeb());

  @Put(path: '/{favoredId}')
  Future<Response> _putId(
    @Path() String favoredId,
  );
  Future<Response?> putId(@Path() String favoredId) =>
      tokenRequest(() => _putId(favoredId));

  @Delete(path: '/{favoredId}')
  Future<Response> _delId(@Path() String favoredId);
  Future<Response?> delId(@Path() String favoredId) =>
      tokenRequest(() => _delId(favoredId));

  @Get(path: '/{favoredId}')
  Future<Response> _getIdList(
    @Path() String favoredId,
    @Query() int page,
    @Query() int pageSize,
    @Query() String sort,
  );
  Future<Response?> getIdList(
    String favoredId,
    int page,
    int pageSize,
    String sort,
  ) =>
      tokenRequest(() => _getIdList(favoredId, page, pageSize, sort));

  @Put(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> _putNovelId(
    @Path() String favoredId,
    @Path() String providerId,
    @Path() String novelId,
  );
  Future<Response?> putNovelId(
    String favoredId,
    String providerId,
    String novelId,
  ) =>
      tokenRequest(() => _putNovelId(favoredId, providerId, novelId));

  @Delete(path: '/{favoredId}/{providerId}/{novelId}')
  Future<Response> _deleteNovelId(
    @Path() String favoredId,
    @Path() String providerId,
    @Path() String novelId,
  );
  Future<Response?> deleteNovelId(
    String favoredId,
    String providerId,
    String novelId,
  ) =>
      tokenRequest(() => _deleteNovelId(favoredId, providerId, novelId));

  static UserFavoredWebService create([ChopperClient? client]) =>
      _$UserFavoredWebService(client);
}