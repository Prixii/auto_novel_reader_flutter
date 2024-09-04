import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField buildTextField(
  String hint,
  TextEditingController controller, {
  List<TextInputFormatter>? inputFormatters,
  int? maxLines = 1,
  bool? obscureText,
  String? errorText,
  TextInputType? keyboardType,
  FormFieldValidator<String?>? validator,
}) {
  return TextFormField(
    keyboardType: keyboardType,
    controller: controller,
    style: const TextStyle(
      fontSize: 16.0,
      height: 1,
      textBaseline: TextBaseline.ideographic,
    ),
    decoration: InputDecoration(
      labelText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.all(14),
      errorText: errorText,
    ),
    obscureText: obscureText ?? false,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    validator: validator,
  );
}
