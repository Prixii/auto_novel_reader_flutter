part of 'service.dart';

@ChopperApi(baseUrl: '/novel')
abstract class WebNovelService extends ChopperService {
  @Get(path: '')
  Future<Response> getList(
    @Query() int page,
    @Query() int pageSize, {
    @Query() String provider = "",
    @Query() int type = 0,
    @Query() int level = 0,
    @Query() int translate = 0,
    @Query() int sort = 0,
    @Query() String? query,
  });

  @Get(path: '/rank/{providerId}')
  Future<Response> getRank(@Path() String providerId);

  @Get(path: '/{providerId}/{novelId}')
  Future<Response> getNovelId(
      @Path() String providerId, @Path() String novelId);

  @Get(path: '/{providerId}/{novelId}/chapter/{chapterId}')
  Future<Response> getChapter(@Path() String providerId, @Path() String novelId,
      @Path() String chapterId);

  @Post(path: '/{providerId}/{novelId}')
  Future<Response> postNovelId(
      @Path() String providerId, @Path() String novelId);

  @Put(path: '/{providerId}/{novelId}/glossary')
  Future<Response> putGlossary(
      @Path() String providerId, @Path() String novelId);

  @Get(path: '/{providerId}/{novelId}/translate-v2/{translatorId}')
  Future<Response> getTranslateV2(@Path() String providerId,
      @Path() String novelId, @Path() String translatorId);

  @Post(
      path:
          '/{providerId}/{novelId}/translate-v2/{translatorId}/chapter-task/{chapterId}')
  Future<Response> postTranslateV2Task(
      @Path() String providerId,
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String chapterId);

  @Post(path: '/{providerId}/{novelId}/translate-v2/{translatorId}/metadata')
  Future<Response> postTranslateV2Metadata(@Path() String providerId,
      @Path() String novelId, @Path() String translatorId);

  @Post(
      path:
          '/{providerId}/{novelId}/translate-v2/{translatorId}/chapter/{chapterId}')
  Future<Response> postChapter(
      @Path() String providerId,
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String chapterId);

  @Get(path: '/{providerId}/{novelId}/file')
  Future<Response> getFile(@Path() String providerId, @Path() String novelId);

  static WebNovelService create([ChopperClient? client]) =>
      _$WebNovelService(client);
}
