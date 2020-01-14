import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';
import 'package:flutter_attendance/shared/loader.dart';

class TardyOptions extends StatefulWidget {
  @override
  _TardyOptionsState createState() => _TardyOptionsState();
}

class _TardyOptionsState extends State<TardyOptions> {
  Map<String, String> map = {'reason': null, 'comments': ''};

  var _formKey = GlobalKey<FormState>();
  bool _dropdownError = false;

  _validateForm() {
    if(map["reason"] == null) {
      setState(() => _dropdownError = true);
    } else {
      Navigator.pop(context, map);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tardy Options"),
        ),
        body: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Text(
                              _dropdownError == true ? 'Please Select a Reason' : '',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 10.0),
                          DropdownButtonFormField(
                            decoration: decoration.copyWith(labelText: 'Select a Tardy Reason'),
                            value: map["reason"],
                            items: reasons.keys.map((item) {
                              return DropdownMenuItem(
                                  value: item, child: Text('$item')
                              );
                            }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  map["reason"] = value;
                                  _dropdownError = null;
                                });
                              },
                          ),
                          SizedBox(height: 20.0),
                          CustomTextField(labelText: 'Comments', onChanged: (val) => setState(() => map['comments'] = val)),
                          SizedBox(height:20.0),
                          RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5)
                              ),
                              color: Colors.teal[200],
                              child: Text('Submit'),
                              onPressed:() {
                                _validateForm();
                              }
                          )
                        ],
                      ),
                    )),
              ),
            )
        )
    );
  }
}
