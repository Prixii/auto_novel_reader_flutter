import 'package:flutter/material.dart';

class SinglePagePainter extends CustomPainter {
  const SinglePagePainter(
      {super.repaint, required this.text, this.style, required this.size});
  final TextStyle? style;
  final String text;
  final Size size;
  TextPainter _splitText() {
    final maxHeight = size.height;
    final maxWidth = size.width;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    // double maxWidth = screenSize.width;
    textPainter.layout(
      maxWidth: maxWidth,
    );
    if (textPainter.size.height <= maxHeight) {
      return textPainter;
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
      // 计算可见文本和溢出的文本
    }
    debugPrint('height: ${currentTextPainter!.size.height}\n');
    return currentTextPainter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _splitText().paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
