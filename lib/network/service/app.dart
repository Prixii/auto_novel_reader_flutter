import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:dio/dio.dart';

const url =
    'https://api.github.com/repos/Prixii/auto_novel_reader_flutter/releases/latest';

Future<String?> getLatestRelease(String owner, String repo) async {
  final dio = Dio();
  try {
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return response.data['tag_name'];
    } else {
      errorLogger.logError(
          'dio errorCode: ${response.statusCode}', StackTrace.current,
          extra: 'owner: $owner, repo: $repo');
      return null;
    }
  } catch (e) {
    errorLogger.logError(e, StackTrace.current,
        extra: 'owner: $owner, repo: $repo');
    return null;
  }
}
