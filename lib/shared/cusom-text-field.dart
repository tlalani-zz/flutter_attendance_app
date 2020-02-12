import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/constants.dart';

class CustomTextField extends StatelessWidget {
  final String initialValue;
  final String labelText;
  final Function onChanged;
  final Function validator;
  final bool enabled;
  final bool isPassword;
  final InputDecoration textDecoration;
  final TextAlign textAlign;
  final TextEditingController controller;
  const CustomTextField(
      {this.initialValue,
      this.labelText,
      this.onChanged,
      this.validator,
      this.isPassword = false,
      this.enabled = true,
      this.controller = null,
      this.textDecoration,
      this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TextFormField(
      textAlign: textAlign,
      initialValue: initialValue,
      controller: controller,
      enabled: enabled,
      decoration: this.textDecoration != null
          ? this.textDecoration
          : decoration.copyWith(labelText: labelText),
      onChanged: onChanged,
      validator: validator,
      obscureText: isPassword,
    ));
  }
}
