import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/constants.dart';

class CustomTextField extends StatelessWidget {

  final String labelText;
  final Function onChanged;
  final Function validator;
  final bool enabled;
  final bool isPassword;
  final TextEditingController controller;
  const CustomTextField({Key key, this.labelText, this.onChanged, this.validator, this.isPassword = false, this.enabled = true, this.controller = null}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: decoration.copyWith(labelText: labelText),
        onChanged: onChanged,
        validator: validator,
        obscureText: isPassword,
      )
    );
  }
}
