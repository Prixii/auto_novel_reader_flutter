part of 'service.dart';

@ChopperApi(baseUrl: '/article')
abstract class ArticleService extends ChopperService {
  @Get(path: '')
  Future<Response> getArticleList();

  @Get(path: '/{id}')
  Future<Response> getId(@Path() String id);

  @Post(path: '')
  Future<Response> postArticle();

  @Put(path: '/{id}')
  Future<Response> putId(@Path() String id);

  @Delete(path: '/{id}')
  Future<Response> delId(@Path() String id);

  @Put(path: '/{id}/locked')
  Future<Response> putIdLocked(@Path() String id);

  @Delete(path: '/{id}/locked')
  Future<Response> delIdLocked(@Path() String id);

  @Put(path: '/{id}/pinned')
  Future<Response> putIdPinned(@Path() String id);

  @Delete(path: '/{id}/pinned')
  Future<Response> delPinned(@Path() String id);

  @Put(path: '/{id}/hidden')
  Future<Response> putIdHidden(@Path() String id);

  @Delete(path: '/{id}/hidden')
  Future<Response> delIdHidden(@Path() String id);

  static ArticleService create([ChopperClient? client]) =>
      _$ArticleService(client);
}
