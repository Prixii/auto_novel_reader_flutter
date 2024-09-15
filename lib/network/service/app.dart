import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:dio/dio.dart';

const url = '/Prixii/auto_novel_reader_flutter/releases/latest';
final _dio = Dio(BaseOptions(
  baseUrl: 'https://api.github.com/repos',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  sendTimeout: const Duration(seconds: 5),
));

Future<ReleaseData?> getLatestRelease() async {
  try {
    final response = await _dio.get(
      url,
    );
    if (response.statusCode == 200) {
      final releaseData = ReleaseData(
        tag: response.data['tag_name'],
        body: response.data['body'],
        htmlUrl: response.data['html_url'],
      );
      return releaseData;
    } else {
      showErrorToast('获取最新版本失败');
      errorLogger.logError(
        'dio errorCode: ${response.statusCode}',
        StackTrace.current,
      );
      return null;
    }
  } catch (e) {
    showErrorToast('获取最新版本失败');
    errorLogger.logError(
      e,
      StackTrace.current,
    );
    return null;
  }
}
