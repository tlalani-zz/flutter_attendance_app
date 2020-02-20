import 'package:flutter/material.dart';

import 'constants/constants.dart';

class StatusDropdown extends StatelessWidget {

  final dynamic value;
  final Function onChanged;

  const StatusDropdown({this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: decoration.copyWith(labelText: 'Select a Tardy Reason'),
      value: value,
      items: StatusType.values.map((item) {
        return DropdownMenuItem(
            value: item, child: Text(statusToString(item))
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
