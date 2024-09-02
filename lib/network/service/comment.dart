part of 'service.dart';

@ChopperApi(baseUrl: '/comment')
abstract class CommentService extends ChopperService {
  @Get(path: '')
  Future<Response> getCommentList();

  @Post(path: '')
  Future<Response> _postComment();
  Future<Response?> postComment() => tokenRequest(() => _postComment());

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
