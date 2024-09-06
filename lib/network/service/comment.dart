part of 'service.dart';

@ChopperApi(baseUrl: '/comment')
abstract class CommentService extends ChopperService {
  @Get(path: '')
  Future<Response> getCommentList(
    @Query() String site,
    @Query() int page,
    @Query() int pageSize,
  );

  @Post(path: '')
  Future<Response> _postComment(@Body() body);
  Future<Response?> postComment({
    required String content,
    String? parent,
    required String site,
  }) =>
      tokenRequest(() => _postComment((parent == null)
          ? {
              'content': content,
              'parent': parent,
              'site': site,
            }
          : {
              'content': content,
              'site': site,
            }));

  @Put(path: '/{id}/hidden')
  Future<Response> _putIdHidden(@Path() String id);
  Future<Response?> putIdHidden(@Path() String id) =>
      tokenRequest(() => _putIdHidden(id));

  @Delete(path: '/{id}/hidden')
  Future<Response> _delIdHidden(@Path() String id);
  Future<Response?> delIdHidden(@Path() String id) =>
      tokenRequest(() => _delIdHidden(id));

  static CommentService create([ChopperClient? client]) =>
      _$CommentService(client);
}
