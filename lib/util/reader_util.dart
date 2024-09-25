import 'dart:async';
import 'dart:math';

import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:auto_novel_reader_flutter/model/model.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReaderUtil {
  // TODO 支持翻译样式
  static Future<List<PagedData>> pagingText(
    ChapterDto dto,
    Size size,
  ) async {
    var result = <PagedData>[];
    final webConfig = configCubit.state.webNovelConfig;
    final translationMode = webConfig.translationMode;
    final order = webConfig.translationSourcesOrder;
    final translationEnabled = webConfig.translationSourcesEnabled;

    List<TranslationSource> translationSources = [];

    for (var source in order) {
      if (translationEnabled[source] == true) {
        late List<String>? paragraphList;
        switch (source) {
          case TranslationSource.youdao:
            paragraphList = dto.youdaoParagraphs;
            break;
          case TranslationSource.baidu:
            paragraphList = dto.baiduParagraphs;
            break;
          case TranslationSource.gpt:
            paragraphList = dto.gptParagraphs;
            break;
          case TranslationSource.sakura:
            paragraphList = dto.sakuraParagraphs;
        }
        if (paragraphList != null && paragraphList.isNotEmpty) {
          translationSources.add(source);
        }
      }
    }
    if (translationMode == TranslationMode.priority) {
      translationSources = [translationSources.first];
    }

    final appearanceConfig = configCubit.state.novelAppearanceConfig;
    final mainTextStyle = appearanceConfig.textStyle;
    final subTextStyle = appearanceConfig.subTextStyle;

    final originalParagraphs = dto.originalParagraphs ?? [];
    final youdaoParagraphs = dto.youdaoParagraphs;
    final baiduParagraphs = dto.baiduParagraphs;
    final gptParagraphs = dto.gptParagraphs;
    final sakuraParagraphs = dto.sakuraParagraphs;

    final maxHeight = size.height;
    final maxWidth = size.width;

    var currentPagedParagraph = const PagedData();
    var heightLast = maxHeight;

    for (int i = 0; i < originalParagraphs.length; i++) {
      late String textToAppend;
      for (var j = 0; j < translationSources.length + 1; j++) {
        if (j == 0) {
          textToAppend = originalParagraphs[i];
        } else {
          final source = translationSources[j - 1];
          switch (source) {
            case TranslationSource.youdao:
              textToAppend = youdaoParagraphs![i];
              break;
            case TranslationSource.baidu:
              textToAppend = baiduParagraphs![i];
              break;
            case TranslationSource.gpt:
              textToAppend = gptParagraphs![i];
              break;
            case TranslationSource.sakura:
              textToAppend = sakuraParagraphs![i];
              break;
          }
        }
        // textToAppend += '\n';
        // 处理图片渲染
        final (isImage, url) = tryParseImg(textToAppend);
        if (isImage) {
          final imageSize = await getImageRenderSize(
            url,
            maxHeight,
            maxWidth,
          );
          final imageHeight = imageSize.height;
          final imageWidth = imageSize.width;
          if (imageHeight > heightLast) {
            // 超出指定高度，则另起一页
            result.add(currentPagedParagraph);
            heightLast = maxHeight - imageHeight;
            currentPagedParagraph = const PagedData().append(
              WebNovelContentType.image,
              textToAppend,
              imageHeight,
              imageWidth,
            );
          } else {
            // 否则直接添加到文本后面
            heightLast -= imageHeight;
            currentPagedParagraph = currentPagedParagraph.append(
              WebNovelContentType.image,
              textToAppend,
              imageHeight,
              imageWidth,
            );
          }
          continue;
        }

        final style = j == 0 ? mainTextStyle : subTextStyle;
        final type = j == 0
            ? WebNovelContentType.original
            : WebNovelContentType.translation;
        // 处理普通文本
        while (textToAppend != '') {
          final (splitIndex, finalHeight) = _splitText(
            textToAppend,
            size.width,
            heightLast,
            style,
          );
          final visibleText = textToAppend.substring(0, splitIndex);
          textToAppend = textToAppend.substring(splitIndex);
          if (textToAppend != '') {
            // 溢出，则另起一页
            result.add(currentPagedParagraph);
            currentPagedParagraph = const PagedData().append(
              type,
              visibleText,
              finalHeight,
              size.width,
            );
            heightLast = maxHeight - finalHeight;
          } else {
            currentPagedParagraph = currentPagedParagraph.append(
              type,
              visibleText,
              finalHeight,
              size.width,
            );
            heightLast = heightLast - finalHeight;
          }
        }

        // 处理最后一个文本
        if ((i == originalParagraphs.length - 1) &&
            (j == translationSources.length)) {
          final (_, finalHeight) = _splitText(
            textToAppend,
            size.width,
            heightLast,
            style,
          );
          currentPagedParagraph = currentPagedParagraph.append(
            type,
            textToAppend,
            finalHeight,
            size.width,
          );
          result.add(currentPagedParagraph);
        }
      }
    }
    return result;
  }

  static (int splitIndex, double finalHeight) _splitText(
    String additional,
    double maxWidth,
    double maxHeight,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: additional, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.size.height <= maxHeight) {
      return (additional.length, textPainter.size.height);
    }

    int endIndex = additional.length;
    int startIndex = 0;
    double finalHeight = 0;
    while (startIndex < endIndex) {
      int middle = (startIndex + endIndex) ~/ 2;

      finalHeight = _calcTextHeight(
        additional.substring(0, middle),
        style,
        maxWidth,
      );

      if (finalHeight > maxHeight) {
        endIndex = middle;
      } else {
        startIndex = middle + 1;
      }
    }
    return (startIndex, finalHeight);
  }

  static (bool, String) tryParseImg(String paragraph) {
    final isImg = paragraph.startsWith('<图片>');
    final url = isImg ? paragraph.substring(4) : '';
    return (isImg, url);
  }

  static Future<ImageInfo> _getImageInfo(String url) async {
    final completer = Completer<ImageInfo>();
    CachedNetworkImageProvider(url)
        .resolve(const ImageConfiguration())
        .addListener(
      ImageStreamListener((ImageInfo info, bool sync) {
        completer.complete(info);
      }),
    );
    return await completer.future;
  }

  static Future<Size> getImageRenderSize(
    String url,
    double maxHeight,
    double maxWidth,
  ) async {
    final imageInfo = await _getImageInfo(url);
    final actualImageHeight = imageInfo.image.height.toDouble();
    final actualImageWidth = imageInfo.image.width.toDouble();

    final viewImageHeight = actualImageWidth > maxWidth
        ? actualImageHeight * (maxWidth / actualImageWidth)
        : actualImageHeight;
    final renderHeight = min(viewImageHeight, maxHeight);
    final renderWidth = actualImageWidth * (renderHeight / actualImageHeight);
    return Size(renderWidth, renderHeight);
  }

  static double _calcTextHeight(
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: maxWidth,
      );

    return painter.size.height;
  }
}
