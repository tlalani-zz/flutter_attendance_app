import 'package:flutter/material.dart';

import 'constants.dart';

class ReasonDropdown extends StatelessWidget {
  final dynamic value;
  final Function onChanged;
  final bool enabled;
  final String labelText;

  const ReasonDropdown(
      {this.labelText = 'Select a Tardy Reason',
      this.value,
      this.onChanged,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: decoration.copyWith(labelText: labelText),
      value: value,
      items: reasons.keys.map((item) {
        return DropdownMenuItem(value: item, child: Text('$item'));
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
