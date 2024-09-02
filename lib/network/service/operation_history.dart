part of 'service.dart';

@ChopperApi(baseUrl: '/operation-history')
abstract class OperationHistoryService extends ChopperService {
  @Get(path: '')
  Future<Response> getOperationHistory();

  @Get(path: '/toc-merge/')
  Future<Response> getTocList();

  @Delete(path: '/{id}')
  Future<Response> _delId(@Path() String id);
  Future<Response?> delId(@Path() String id) => tokenRequest(() => _delId(id));

  @Delete(path: '/toc-merge/{id}')
  Future<Response> _delTocId(@Path() String id);
  Future<Response?> delTocId(@Path() String id) =>
      tokenRequest(() => _delTocId(id));

  static OperationHistoryService create([ChopperClient? client]) =>
      _$OperationHistoryService(client);
}
