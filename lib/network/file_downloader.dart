import 'dart:io';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/util/error_logger.dart';
import 'package:dio/dio.dart';

Future<File?> downloadFile({
  required String url,
  required String path,
  required String filename,
  bool wenku = false,
}) async {
  File file = File('$path/$filename');
  if (!file.existsSync()) {
    file.createSync();
  }
  if (wenku) {
    return await _downloadWenkuEpub(url, filename, file);
  }
  return await _downloadZhEpub(url, filename, file);
}

Future<File?> _downloadWenkuEpub(String url, String filename, File file) async {
  try {
    var redirectResponse = await Dio().get(
      url,
    );
    final rawRedirectUrlPart = redirectResponse.realUri.path;
    final redirectUrlPart = rawRedirectUrlPart.replaceAll('../', '');
    final redirectUrl = 'https://${configCubit.state.host}/$redirectUrlPart';
    downloadCubit.finishRedirect(filename);
    var response = await Dio().get(
      redirectUrl,
      onReceiveProgress: (num received, num total) {
        double process = double.parse((received / total).toStringAsFixed(4));
        downloadCubit.updateProgress(filename, process);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );
    file.writeAsBytesSync(response.data);
    downloadCubit.finishDownload(filename, true, file: file);
    return file;
  } on DioException catch (e, stackTrace) {
    downloadCubit.downloadFailed(filename);
    showErrorToast('下载失败: ${e.type}');
    errorLogger.logError(e, stackTrace);
    return null;
  }
}

Future<File?> _downloadZhEpub(String url, String filename, File file) async {
  try {
    var response = await Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
    )).get(
      url,
      onReceiveProgress: (num received, num total) {
        double process = double.parse((received / total).toStringAsFixed(4));
        downloadCubit.updateProgress(filename, process);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );
    file.writeAsBytesSync(response.data);
    return file;
  } on DioException catch (e, stackTrace) {
    errorLogger.logError(e, stackTrace);
    downloadCubit.downloadFailed(filename);
    showErrorToast('下载失败: ${e.type}');
    return null;
  }
}

String zhDownloadUrlGenerator(String novelId, String volumeId) {
  final volumeUri = Uri.encodeComponent(volumeId);
  return 'https://${configCubit.state.host}/files-wenku/$novelId/$volumeUri';
}

(String filename, String url) jpDownloadUrlGenerator(
  String novelId,
  String volumeId, {
  required Language mode,
  required TranslationMode translationsMode,
  required List<TranslationSource> translations,
}) {
  if (mode == Language.jp) throw Exception('mode must not be jp');
  final volumeUri = Uri.encodeComponent(volumeId);
  final translationCode = (translationsMode.name == 'parallel' ? 'B' : 'Y');
  final translationSource =
      translations.map((source) => source.name[0]).join('');
  final filename = [
    mode.kebabName,
    '$translationCode$translationSource',
    volumeId
  ].join('.');

  final translationParam = translations
      .map((translation) => '&translations=${translation.name}')
      .join('');
  final params = Uri(queryParameters: {
    'mode': mode.kebabName,
    'translationsMode': translationsMode.name,
    'filename': filename,
  }).query;

  return (
    filename,
    'https://${configCubit.state.host}/api/wenku/$novelId/file/$volumeUri?$params$translationParam'
  );
}
