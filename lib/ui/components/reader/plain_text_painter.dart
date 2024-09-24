import 'package:flutter/material.dart';

class PlainTextPainter extends CustomPainter {
  const PlainTextPainter(
      {super.repaint, required this.text, this.style, required this.size});
  final TextStyle? style;
  final String text;
  final Size size;
  TextPainter _splitText() {
    final maxWidth = size.width;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      maxWidth: maxWidth,
    );
    return textPainter;
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
