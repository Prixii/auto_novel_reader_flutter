part of 'service.dart';

@ChopperApi(baseUrl: '/wenku')
abstract class WenkuNovelService extends ChopperService {
  @Get(path: '')
  Future<Response> getList(
    @Query() int page,
    @Query() int pageSize, {
    @Query() String? query,
    @Query() int level = 0,
  });

  @Get(path: '/{novelId}')
  Future<Response> getId(@Path() String novelId);

  @Post(path: '')
  Future<Response> postNovel();

  @Put(path: '/{novelId}')
  Future<Response> putId(@Path() String novelId);

  @Put(path: '/{novelId}/glossary')
  Future<Response> putGlossary(@Path() String novelId);

  @Post(path: '/{novelId}/volume/{volumeId}')
  Future<Response> postVolume(@Path() String novelId, @Path() String volumeId);

  @Delete(path: '/{novelId}/volume/{volumeId}')
  Future<Response> delVolume(@Path() String novelId, @Path() String volumeId);

  @Get(path: '/{novelId}/translate-v2/{translatorId}/{volumeId}')
  Future<Response> getTranslateV2Volume(@Path() String novelId,
      @Path() String translatorId, @Path() String volumeId);

  @Get(
      path:
          '/{novelId}/translate-v2/{translatorId}/{volumeId}/chapter-task/{chapterId}')
  Future<Response> getTranslateV2ChapterTask(
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String volumeId,
      @Path() String chapterId);

  @Post(
      path:
          '/{novelId}/translate-v2/{translatorId}/{volumeId}/chapter/{chapterId}')
  Future<Response> postTranslateV2Chapter(
      @Path() String novelId,
      @Path() String translatorId,
      @Path() String volumeId,
      @Path() String chapterId);

  static WenkuNovelService create([ChopperClient? client]) =>
      _$WenkuNovelService(client);
}
