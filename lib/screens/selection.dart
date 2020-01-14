import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';
import 'package:flutter_attendance/shared/loader.dart';

class ReOptionsSelect extends StatefulWidget {
  @override
  _ReOptionsSelectState createState() => _ReOptionsSelectState();
}

class _ReOptionsSelectState extends State<ReOptionsSelect> {
  List<String> centers;
  List<String> classes = [];
  List<String> shifts = [];
  Map<dynamic, dynamic> options;
  ReConfig config = new ReConfig();
  DatabaseService _db = new DatabaseService();
  bool loading;

  Future<void> getConfig() async {
    options = await _db.getCenters();
    centers = options.keys.toList().cast<String>();
    setState(() => loading = false);
    print(centers);
  }

  List<String> getShifts(val) {
    List<String> res = [];
    List<String> days = options[config.re_center][val].keys.toList().cast<String>();
    for(String day in days) {
      for(String time in options[config.re_center][val][day].cast<String>()) {
        res.add('$day, $time');
      }
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    getConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Select Your REC"),
        ),
        body: loading == true
            ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Getting Your User Information'),
              SizedBox(height: 40.0),
              Loader(),
            ]
        )
            : Container(
                child: Center(
                  child: SingleChildScrollView(
                  child: Form(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: Image.network(logoPicture),
                        ),
                        SizedBox(height: 20.0),
                    DropdownButtonFormField(
                      decoration: decoration.copyWith(labelText: 'Select A Center'),
                      value: config.re_center,
                      items: centers.map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text('$item')
                        );
                      }).toList(),
                      onChanged: (val) => setState(() {
                        config.re_center = val;
                        setState(() => classes = options[val].keys.toList().cast<String>());
                      }),
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField(
                      decoration: decoration.copyWith(labelText: 'Select A Class'),
                      value: config.re_class,
                      items:  classes.map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text('$item'));
                      }).toList(),
                      onChanged: (val) => setState(() {
                        config.re_class = val;
                        setState(() => shifts = getShifts(val));
                      }),
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField(
                      decoration: decoration.copyWith(labelText: 'Select A Shift'),
                      value: config.re_shift,
                      items: shifts.map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text('$item'));
                      }).toList(),
                      onChanged: (val) => setState(() {
                        config.re_shift = val;
                      }),
                    ),
                    SizedBox(height:20.0),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5)
                        ),
                        color: Colors.teal[200],
                        child: Text('Submit'),
                        onPressed: config.re_shift == null ? null : () {
                          _db.setConfig(config);
                          Navigator.popAndPushNamed(context, '/home');
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
