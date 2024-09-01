part of 'service.dart';

@ChopperApi(baseUrl: '/comment')
abstract class CommentService extends ChopperService {
  @Get(path: '')
  Future<Response> getCommentList();

  @Post(path: '')
  Future<Response> postComment();

  @Put(path: '/{id}/hidden')
  Future<Response> putIdHidden(@Path() String id);

  @Delete(path: '/{id}/hidden')
  Future<Response> delIdHidden(@Path() String id);

  static CommentService create([ChopperClient? client]) =>
      _$CommentService(client);
}
