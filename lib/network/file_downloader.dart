import 'dart:io';
import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:dio/dio.dart';

Future<File?> downloadFile({
  required String url,
  required String path,
  required String fileName,
  bool wenku = false,
}) async {
  File file = File('$path/$fileName');
  if (!file.existsSync()) {
    file.createSync();
  }
  if (wenku) {
    return await _downloadWenkuEpub(url, fileName, file);
  }
  return await _downloadZhEpub(url, fileName, file);
}

Future<File?> _downloadWenkuEpub(String url, String fileName, File file) async {
  try {
    var redirectResponse = await Dio().get(
      url,
    );
    final rawRedirectUrlPart = redirectResponse.realUri.path;
    final redirectUrlPart = rawRedirectUrlPart.replaceAll('../', '');
    final redirectUrl = 'https://${configCubit.state.host}/$redirectUrlPart';
    var response = await Dio().get(
      redirectUrl,
      onReceiveProgress: (num received, num total) {
        double process = double.parse((received / total).toStringAsFixed(4));
        downloadCubit.updateProgress(fileName, process);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );
    file.writeAsBytesSync(response.data);
    return file;
  } on DioException catch (e) {
    downloadCubit.downloadFailed(fileName);
    showErrorToast('下载失败: ${e.type}');
    return null;
  }
}

Future<File?> _downloadZhEpub(String url, String fileName, File file) async {
  try {
    var response = await Dio().get(
      url,
      onReceiveProgress: (num received, num total) {
        double process = double.parse((received / total).toStringAsFixed(4));
        downloadCubit.updateProgress(fileName, process);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );
    file.writeAsBytesSync(response.data);
    return file;
  } on DioException catch (e) {
    downloadCubit.downloadFailed(fileName);
    showErrorToast('下载失败: ${e.type}');
    return null;
  }
}

String zhDownloadUrlGenerator(String novelId, String volumeId) {
  final volumeUri = Uri.encodeComponent(volumeId);
  return 'https://${configCubit.state.host}/files-wenku/$novelId/$volumeUri';
}

(String fileName, String url) jpDownloadUrlGenerator(
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
  final fileName = [
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
    'filename': fileName,
  }).query;

  return (
    fileName,
    'https://${configCubit.state.host}/api/wenku/$novelId/file/$volumeUri?$params$translationParam'
  );
}
