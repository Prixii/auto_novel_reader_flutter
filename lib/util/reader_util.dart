import 'package:auto_novel_reader_flutter/ui/components/reader/single_page_painter.dart';
import 'package:flutter/material.dart';

class ReaderUtil {
  static CustomPaint buildPagedText({
    required Size size,
    required String text,
    required TextStyle style,
  }) =>
      CustomPaint(
          size: size,
          painter: SinglePagePainter(text: text, style: style, size: size));

  static List<String> pagingText(String text, Size size, TextStyle style) {
    var result = <String>[];
    var textRemain = text;
    while (textRemain.isNotEmpty) {
      final (visible, invisible) = _splitText(textRemain, size, style);
      result.add(visible);
      textRemain = invisible;
    }
    return result;
  }

  static (String visibleText, String overflowText) _splitText(
    String text,
    Size size,
    TextStyle style,
  ) {
    final maxHeight = size.height;
    final maxWidth = size.width;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.size.height <= maxHeight) {
      return (text, '');
    }

    int endIndex = text.length;
    int startIndex = 0;
    TextPainter? currentTextPainter;
    while (startIndex < endIndex) {
      int middle = (startIndex + endIndex) ~/ 2;
      currentTextPainter = TextPainter(
        text: TextSpan(text: text.substring(0, middle), style: style),
        textDirection: TextDirection.ltr,
      );
      currentTextPainter.layout(
        maxWidth: maxWidth,
      );

      if (currentTextPainter.size.height > maxHeight) {
        endIndex = middle;
      } else {
        startIndex = middle + 1;
      }
    }
    debugPrint('height: ${currentTextPainter!.size.height}\n');
    final visibleRes = text.substring(0, startIndex);
    final overflowRes = text.substring(startIndex);
    return (visibleRes, overflowRes);
  }
}
