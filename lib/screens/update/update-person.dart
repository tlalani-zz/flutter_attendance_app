import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';
import 'package:flutter_attendance/shared/reason-dropdown.dart';
import 'package:flutter_attendance/shared/status-dropdown.dart';

class UpdatePerson extends StatefulWidget {
  @override
  _UpdatePersonState createState() => _UpdatePersonState();
}

class _UpdatePersonState extends State<UpdatePerson> {
  bool _errored = false;
  Person person;

  @override
  Widget build(BuildContext context) {
    person = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(title: Text('${person.Role} - ${person.Name}')),
        body: Container(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Update ${person.Name}\'s Attendance',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              _errored
                  ? Text(
                      'Please Enter a Reason if the status is ${statusToString(person.Status)}',
                      style: TextStyle(color: Colors.redAccent))
                  : SizedBox(),
              StatusDropdown(
                  value: person.Status,
                  onChanged: (value) {
                    setState(() {
                      person.Status = value;
                    });
                  }),
              ReasonDropdown(
                  value: person.Reason,
                  labelText: 'Select a Reason',
                  onChanged: (value) {
                    setState(() {
                      person.Reason = value;
                    });
                  }),
              CustomTextField(
                  initialValue: person.Comments,
                  onChanged: (value) {
                    setState(() {
                      person.Comments = value;
                    });
                  }),
              RaisedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    _validate(person);
                  },
                  color: Colors.teal[400])
            ],
          ),
        )));
  }

  _validate(Person person) {
    if (person.shouldHaveStatus && person.Reason == null) {
      setState(() {
        _errored = true;
      });
    } else {
      setState(() {
        _errored = false;
      });
      Navigator.pop(context, person);
    }
  }
}
