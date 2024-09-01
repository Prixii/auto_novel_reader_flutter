part of 'service.dart';

@ChopperApi(baseUrl: '/operation-history')
abstract class OperationHistoryService extends ChopperService {
  @Get(path: '')
  Future<Response> getOperationHistory();

  @Get(path: '/toc-merge/')
  Future<Response> getTocList();

  @Delete(path: '/{id}')
  Future<Response> delId(@Path() String id);

  @Delete(path: '/toc-merge/{id}')
  Future<Response> delTocId(@Path() String id);

  static OperationHistoryService create([ChopperClient? client]) =>
      _$OperationHistoryService(client);
}
