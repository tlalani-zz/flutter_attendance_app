import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';
import 'package:flutter_attendance/shared/cusom-text-field.dart';

class ManualEntry extends StatefulWidget {
  @override
  _ManualEntryState createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {

  static DatabaseService _databaseService = new DatabaseService();
  static const String ROLE = "role";
  static const String GRADE = "grade";
  ReConfig config = _databaseService.getConfig();
  Map<dynamic, dynamic> roster;
  List<String> grades;
  bool loading = true;
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
  TextEditingController _controller = new TextEditingController();
  TimeOfDay tardyTime;

  @override
  void initState() {
    setState(() => loading = true);
    _databaseService.getRoster().then((res) => setState((){roster = res;loading = false;}));
    grades = config.grades;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getNames({String context, DateTime dt}) async {
    if(dt == null) {
      switch(context) {
        case ROLE:
          setState(() => names = (roster[map["role"]]["people"] as List).cast<String>());
          break;
        case GRADE:
          setState(() => names = (roster[map["role"]][map["grade"]] as List).cast<String>());
          break;
        default:
          setState(() => names = null);
      }
    } else {
      _getNames(dt);
    }
  }

  Future<void> _getNames(DateTime newDT) async {
    if(getSchoolYear(dt: newDT) != getSchoolYear(dt: map["date"])) {
      roster = await _databaseService.getRoster(dt: newDT);
      setState(() {
        map = reInitMap();
        map["date"] = newDT;
      });
    } else {
      setState(() => map["date"] = newDT);
    }
  }

  Future<Null> pickDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: map["date"],
        firstDate: DateTime(2017, 8),
        lastDate: DateTime(DateTime.now().year + 1, 6));
    if (picked != null) {
      getNames(dt: picked);
    }
  }

  Future<Null> pickTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: map["time"]);
    if (picked != null) {
      setState(() => map["time"] = picked);
      if(!isTardy()) {
        map["reason"] = null;
        map["comments"]=null;
        _controller.clear();
      }
    }
  }

  bool shouldHaveGrade() {
    return
      !(map["role"].toString().isEmpty ||
        (map["role"].toString().toLowerCase() == "management" ||
            map["role"].toString().toLowerCase() == "intern"));
  }

  validateForm(BuildContext context) {
    String s = "";
    bool tardyWithNoReason = isTardy() && map["reason"] == null;
    bool roleWithNoGradeAndGradeSelected = !shouldHaveGrade() && map["grade"] != null;
    bool roleWithGradeAndNoGradeSelected = shouldHaveGrade() && map["grade"] == null;
    bool selectedDayNotCorrectRECDay = (map["date"] as DateTime).weekday != daysOfWeek.indexOf(config.day) + 1;
    bool selectedTimeIsBeforeShiftStart = isBefore(map["time"], config.earliestStartTime);
    bool selectedTimeIsAfterShiftEnd = isAfter(map["time"], config.latestEndTime);
    if(tardyWithNoReason)
      s += '-> Please Enter a Reason for Tardy Student.\n\n';
    if(roleWithNoGradeAndGradeSelected)
      s += "-> The selected role shouldn't have a grade.\n\n";
    if(roleWithGradeAndNoGradeSelected)
      s += "-> The selected role should have a grade.\n\n";
    if(selectedDayNotCorrectRECDay)
      s += "-> The date you selected is on a ${daysOfWeek[map["date"].weekday - 1]}. Your REC day is ${config.day}.\n\n";
    if(selectedTimeIsBeforeShiftStart)
      s += "-> The time you selected ${toDbTime(map["time"])} is earlier than the possible start time of ${toDbTime(config.earliestStartTime)}.\n\n";
    if(selectedTimeIsAfterShiftEnd)
      s += "-> The time you selected ${toDbTime(map["time"])} is later than the possible end time of ${toDbTime(config.latestEndTime)}.\n\n";
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
        Name: map["name"],
        Grade: map["grade"],
        Role: map["role"],
        Reason: map["reason"],
        Comments: map["comments"],
        time: map["time"],
        tardyTime: tardyTime
    );
  }

  reInitMap() {
    return {
      "role": null,
      "grade": null,
      "date": DateTime.now(),
      "time": TimeOfDay.now(),
      "name": null,
      "reason": null,
      "comments": null
    };
  }

  @override
  Widget build(BuildContext context) {
    tardyTime = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(title: Text("Manual Entry"), actions: <Widget>[
          IconButton(icon: Icon(Icons.group), onPressed: () { Navigator.pushReplacementNamed(context, "/roster");}),
        ],),
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
                                  map["grade"] = null;
                                  map["name"] = null;
                                  names = null;
                                });
                                if(!shouldHaveGrade()) {
                                  getNames(context: ROLE);
                                }
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
                              onChanged: !shouldHaveGrade() ? null : (val) {
                                setState(() {
                                  map["grade"] = val;
                                });
                                getNames(context: GRADE);
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
