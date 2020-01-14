import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';

class ManualEntry extends StatefulWidget {
  @override
  _ManualEntryState createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {

  static DatabaseService _databaseService = new DatabaseService();
  ReConfig config = _databaseService.getConfig();
  get startTime => TimeOfDay(hour: 5, minute: 0);
  get endTime => config.shiftEndTime.replacing(hour: config.shiftEndTime.hour + 1);
  List<String> grades;
  Map<String, dynamic> map = {
    "role": null,
    "grade": null,
    "date": DateTime.now(),
    "time": TimeOfDay.now(),
    "name": null,
    "reason": null,
    "comments": null
  };
  List<String> names = [];
  String schoolYear = getSchoolYear(dt: DateTime.now());
  TextEditingController _controller = new TextEditingController();
  TimeOfDay tardyTime;

  @override
  void initState() {
    grades = config.getGrades();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getNames(bool optionChange, {DateTime dt}) async {
    if(optionChange) {
      if(dt != null) {
        schoolYear = getSchoolYear(dt: dt);
      }
      _getNames();
    }
    if(dt != null && schoolYear != getSchoolYear(dt: dt)) {
      schoolYear = getSchoolYear(dt: dt);
      _getNames();
    }
  }

  Future<void> _getNames() async {
    List<String> path = ["People", schoolYear, map["role"]];
    if(map["grade"] != null) {
      path.add(map["grade"]);
    }
    try {
      DataSnapshot snapshot = await _databaseService.get(path);
      setState(() => names = (snapshot.value as List).cast<String>());
    } catch(e) {
      setState(() => names = null);
    }
  }

  Future<Null> pickDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: map["date"],
        firstDate: DateTime(1970, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12));
    if (picked != null) {
      setState(() {
        map["date"] = picked;
        getNames(false, dt: picked);
      });
    }
  }

  Future<Null> pickTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: map["time"]);
    if (picked != null) {
      print(picked);
      setState(() => map["time"] = picked);
      if(!isTardy()) {map["reason"] = null;map["comments"]=null;_controller.clear();}
    }
  }

  bool hasNoGrade() {
    return
      map["role"].toString().isEmpty
        ||
        (map["role"].toString().toLowerCase() == "management" ||
            map["role"].toString().toLowerCase() == "intern");
  }

  validateForm(BuildContext context) {
    String s = "";
    bool tardyWithNoReason = isTardy() && map["reason"] == null;
    bool roleWithNoGradeAndGradeSelected = hasNoGrade() && map["grade"] != null;
    bool roleWithGradeAndNoGradeSelected = !hasNoGrade() && map["grade"] == null;
    bool selectedDayNotCorrectRECDay = (map["date"] as DateTime).weekday != daysOfWeek.indexOf(config.day) + 1;
    bool selectedTimeIsBeforeShiftStart = isBefore(map["time"], startTime);
    bool selectedTimeIsAfterShiftEnd = isAfter(map["time"], endTime);
    if(tardyWithNoReason)
      s += '-> Please Enter a Reason for Tardy Student.\n\n';
    if(roleWithNoGradeAndGradeSelected)
      s += "-> The selected role shouldn't have a grade.\n\n";
    if(roleWithGradeAndNoGradeSelected) {
      s += "-> The selected role should have a grade.\n\n";
    }
    if(selectedDayNotCorrectRECDay)
      s += "-> The date you selected is on a ${daysOfWeek[map["date"].weekday - 1]}. Your REC day is ${config.day}.\n\n";
    if(selectedTimeIsBeforeShiftStart)
      s += "-> The time you selected ${toDbTime(map["time"])} is earlier than the possible start time of ${toDbTime(startTime)}.\n\n";
    if(selectedTimeIsAfterShiftEnd)
      s += "-> The time you selected ${toDbTime(map["time"])} is later than the possible end time of ${toDbTime(endTime)}.\n\n";
    if(s.isNotEmpty) {
      showAckDialog(context, "You Have Errors", s);
      return false;
    }
    return true;


  }

  bool isTardy() {
    TimeOfDay time = (map["time"] as TimeOfDay);
    return isAfter(time, tardyTime);
  }

  mapToPerson(map) {
    return new Person(
        name: map["name"],
        grade: map["grade"],
        role: map["role"],
        reason: map["reason"],
        comments: map["comments"],
        time: map["time"],
        tardyTime: tardyTime
    );
  }

  @override
  Widget build(BuildContext context) {
    tardyTime = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(title: Text("Manual Entry")),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 5.0),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField(
                            value: map["role"],
                              decoration:
                                  decoration.copyWith(labelText: "Select a Role"),
                              items: Roles.map((item) {
                                return DropdownMenuItem(
                                    value: item, child: Text('$item'));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  map["role"] = val;
                                  if(hasNoGrade()) {
                                    map["grade"] = null;
                                    getNames(true);
                                  } else {
                                    setState(() {
                                      names = null;
                                      map["name"] = null;
                                    });
                                  }
                                });
                              }),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: map["grade"],
                              decoration: decoration.copyWith(
                                  labelText: "Select a Grade"),
                              items: grades.map((item) {
                                return DropdownMenuItem(
                                    value: item, child: Text('$item'));
                              }).toList(),
                              onChanged: hasNoGrade() ? null : (val) {
                                setState(() {
                                  map["grade"] = val;
                                  getNames(true);
                                });
                              }),
                        ),
                      ]),
                  SizedBox(height:30),
                  DropdownButtonFormField(
                      value: map["name"],
                      decoration:
                      decoration.copyWith(labelText: "Select a Name"),
                      items: names == null ? [] : names.map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text('$item'));
                      }).toList(),
                      onChanged: names == null ? null : (val) {
                        setState(() {
                          map["name"] = val;
                        });
                      }),
                  SizedBox(height:30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Select a Date"),
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.teal[400]),
                            child:
                                Text("   ${toDbDate((map["date"] as DateTime))}   "),
                            onPressed: () {
                              pickDate(context);
                            },
                            shape: new StadiumBorder(),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text("Select a Time"),
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.teal[400]),
                            child:
                                Text("   ${toDbTime((map["time"] as TimeOfDay))}   "),
                            onPressed: () {
                               pickTime(context);
                            },
                            shape: new StadiumBorder(),
                          ),
                        ],
                      ),
                    ],
                  ),
                SizedBox(height:30),
                  DropdownButtonFormField(
                    value: map["reason"],
                      decoration:
                      decoration.copyWith(labelText: "Select a Reason"),
                      items: reasons.keys.cast<String>().toList().map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text('$item'));
                      }).toList(),

                      onChanged: !isTardy() ? null : (val) {
                        setState(() {map["reason"] = val;});
                      }),
                  SizedBox(height:30),
                  CustomTextField(labelText: "Comments", onChanged: (val) {setState(() => map["comments"] = val);}, enabled: isTardy(), controller: _controller),
                  SizedBox(height:30),
                  RaisedButton(
                      child: Text("Submit"),
                      onPressed: () {
                        if(validateForm(context)) {
                          Person p = mapToPerson(map);
                          Navigator.pop(context, p);
                        }
                      })
                ],
              ),
            ),
          ),
        ));
  }
}
