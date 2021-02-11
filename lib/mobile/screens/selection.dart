import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';

class ReOptionsSelect extends StatefulWidget {
  @override
  _ReOptionsSelectState createState() => _ReOptionsSelectState();
}

class _ReOptionsSelectState extends State<ReOptionsSelect> {
  List<String> centers = [];
  List<String> classes = [];
  List<String> shifts = [];
  ReConfig config = new ReConfig();
  DatabaseService _db = new DatabaseService();


  @override
  void initState() {
    super.initState();
    centers = _db.centers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select Your REC"),
        ),
        body: Container(
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Image.asset("images/logo.png"),
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            decoration: decoration.copyWith(
                                labelText: 'Select A Center'),
                            value: config.re_center,
                            items: centers.map((item) {
                              return DropdownMenuItem(
                                  value: item, child: Text('$item'));
                            }).toList(),
                            onChanged: (val) => setState(() {
                              config.re_center = val;
                              setState(() => classes = _db.classes(config.re_center));
                            }),
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            decoration: decoration.copyWith(
                                labelText: 'Select A Class'),
                            value: config.re_class,
                            items: classes.map((item) {
                              return DropdownMenuItem(
                                  value: item, child: Text('$item'));
                            }).toList(),
                            onChanged: (val) => setState(() {
                              config.re_class = val;
                              setState(() => shifts = _db.shifts(config.re_center, config.re_class));
                            }),
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            decoration: decoration.copyWith(
                                labelText: 'Select A Shift'),
                            value: config.re_shift,
                            items: shifts.map((item) {
                              return DropdownMenuItem(
                                  value: item, child: Text('$item'));
                            }).toList(),
                            onChanged: (val) => setState(() {
                              config.re_shift = val;
                            }),
                          ),
                          SizedBox(height: 20.0),
                          RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5)),
                              color: Colors.teal[200],
                              child: Text('Submit'),
                              onPressed: config.re_shift == null
                                  ? null
                                  : () {
                                      _db.setConfig(config);
                                      Navigator.pushNamed(context, '/home');
                                    })
                        ],
                      ),
                    )),
                  ),
                ),
              ));
  }
}
