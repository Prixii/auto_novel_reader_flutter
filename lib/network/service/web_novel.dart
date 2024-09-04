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
  Future<Response> getRank(
    @Path() String providerId,
    @QueryMap() Map<String, String> query,
  );

  @Get(path: '/{providerId}/{novelId}')
  Future<Response> getNovelId(
      @Path() String providerId, @Path() String novelId);

  @Get(path: '/{providerId}/{novelId}/chapter/{chapterId}')
  Future<Response> getChapter(@Path() String providerId, @Path() String novelId,
      @Path() String chapterId);

  @Post(path: '/{providerId}/{novelId}')
  Future<Response> _postNovelId(
      @Path() String providerId, @Path() String novelId);
  Future<Response?> postNovelId(String providerId, String novelId) =>
      tokenRequest(() => _postNovelId(providerId, novelId));

  @Put(path: '/{providerId}/{novelId}/glossary')
  Future<Response> _putGlossary(
      @Path() String providerId, @Path() String novelId);
  Future<Response?> putGlossary(String providerId, String novelId) =>
      tokenRequest(() => _putGlossary(providerId, novelId));

  @Get(path: '/{providerId}/{novelId}/translate-v2/{translatorId}')
  Future<Response> _getTranslateV2(@Path() String providerId,
      @Path() String novelId, @Path() String translatorId);
  Future<Response?> getTranslateV2(
          String providerId, String novelId, String translatorId) =>
      tokenRequest(() => _getTranslateV2(providerId, novelId, translatorId));

  @Post(
      path:
          '/{providerId}/{novelId}/translate-v2/{translatorId}/chapter-task/{chapterId}')
  Future<Response> _postTranslateV2Task(
      @Path() String providerId,
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String chapterId);
  Future<Response?> postTranslateV2Task(String providerId, String novelId,
          String translatorId, String chapterId) =>
      tokenRequest(() =>
          _postTranslateV2Task(providerId, novelId, translatorId, chapterId));

  @Post(path: '/{providerId}/{novelId}/translate-v2/{translatorId}/metadata')
  Future<Response> _postTranslateV2Metadata(@Path() String providerId,
      @Path() String novelId, @Path() String translatorId);
  Future<Response?> postTranslateV2Metadata(
          String providerId, String novelId, String translatorId) =>
      tokenRequest(
          () => _postTranslateV2Metadata(providerId, novelId, translatorId));

  @Post(
      path:
          '/{providerId}/{novelId}/translate-v2/{translatorId}/chapter/{chapterId}')
  Future<Response> _postChapter(
      @Path() String providerId,
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String chapterId);
  Future<Response?> postChapter(String providerId, String novelId,
          String translatorId, String chapterId) =>
      tokenRequest(
          () => _postChapter(providerId, novelId, translatorId, chapterId));

  @Get(path: '/{providerId}/{novelId}/file')
  Future<Response> getFile(@Path() String providerId, @Path() String novelId);

  static WebNovelService create([ChopperClient? client]) =>
      _$WebNovelService(client);
}
