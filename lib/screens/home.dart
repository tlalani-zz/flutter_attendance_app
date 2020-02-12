import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';
import 'package:flutter_attendance/shared/loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final DatabaseService _databaseService = new DatabaseService();
  Map<String, dynamic> roster;
  TimeOfDay tardyTime = TimeOfDay.now();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  Widget build(BuildContext context) {
    getTardyTime();
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
        actions: loading == true ? null : <Widget>[

          IconButton(
            icon: Icon(Icons.person_outline),
            tooltip: 'Update Attendance',
            onPressed: () {
              Navigator.pushNamed(context, '/update');
            }
          ),

          IconButton(
            icon: Icon(Icons.cloud_download),
            tooltip: 'Download Roster',
            onPressed: () async {
              Map<String, dynamic> map = await downloadRoster();
              setState(() => roster = map);
            }
          ),

          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Manual Entry',
            onPressed: () async {
              dynamic person = await Navigator.pushNamed(context, '/manual', arguments: tardyTime);
              if(person != null)
                sendToDatabase(person);
            }
          )
        ],
      ),
      body: Center(
        child: loading == true ? Loader() :
          Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 200,
                    height: 200,
                    child: RaisedButton(
                      color: Colors.teal[400],
                      child: Text('SCAN', style: TextStyle(fontSize: 40, color: Colors.white)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: Colors.teal[400])
                      ),
                      onPressed: roster == null || roster.isEmpty ? null : () async {
                        await scanParseAndSendToDatabase();
                      },
                    ),
                  ),
                  SizedBox(height:40),
                  FlatButton(
                    child: Text('Can\'t find your code?'),
                    onPressed: () {
                      Navigator.pushNamed(context, "/roster");
                    }
                  )
                ],
              ),
            )
          ),
    );
  }

  Future<void> scanParseAndSendToDatabase() async {
    dynamic res = await scanner.scan();
    print("scanned $res");
    //String res = "Student:Jamal Crafer";
    TimeOfDay nowTime = TimeOfDay.now();
    String role = res.split(":")[0];
    String name = res.split(":")[1];
    List<Person> people = findPeople(role, name, nowTime);
    dynamic person;
    if(people.isNotEmpty) {
      person = await showDropdownConfirmDialog(context, res.split(":"), people);
    } else if(kDebugMode) {
      Map<String, String> map = await _databaseService.checkAllShiftsForPerson(role, name, tardyTime);
      String content = 'The student is not in this shift'
          '\n\nCurrent Shift: ${_databaseService.currentShift}'
          '\nStudent\'s Shift: ${map['shiftDay']}, ${map['shiftTime']}'
          '\n\nDo you want to perform a shift transfer?';
      await showConfirmDialog(context, content)
          ? person = new Person(role: role, grade: map['grade'], name: name, time: nowTime, tardyTime: tardyTime)
          : showAckDialog(context, 'Alert', 'Student\'s attendance not saved');
    }
    if (person != null) {
      if (person.status == Status.T) {
        dynamic map = await Navigator.pushNamed(context, "/tardy");
        if(map == null) {
          showAckDialog(context, "Error",
              "There was an error scanning your code, please try again or enter the person manually");
          return;
        }
        person.reason = map["reason"];
        if (map.containsKey("comments")) {
          person.comments = map["comments"];
        }
      }
      sendToDatabase(person);
    } else {
      showAckDialog(context, "Error",
          "There was an error scanning your code, please try again or enter the person manually");
    }
  }

  Future<Person> showDropdownConfirmDialog(BuildContext context, List<String> result, List<Person> people) async {
    List<String> grades = people.map((person) {return person.grade;}).toList();
    String grade = grades[0];
    Widget content =
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Role: ${result[0]}', style: TextStyle(fontSize: 17)),
        SizedBox(height: 8),
        Text('Name: ${result[1]}', style: TextStyle(fontSize: 17)),
        grades == null || grades[0] == null ? Text('') :
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Grade: '),
            DropdownButton(
              isExpanded: false,
              value: grade,
                items: grades.map((item) {
                  return DropdownMenuItem(
                    child: Text('$item'),
                    value: item
                  );
                }).toList(),
                onChanged: (val) {setState(() => grade = val);},
            ),
          ],
        ),
      ],
    );

    List<Widget> actions = [
      FlatButton(
          child: Text('No', style: TextStyle(color: Colors.red[400])),
          onPressed: () {
            Navigator.pop(context, new Map<String, String>());
          }),
      FlatButton(
        child: Text('Yes'),
        onPressed: () {
        Navigator.pop(context, {'grade': grade });
      }),
    ];
    Map<String, String> map = await customDialog(context, "Confirm", content, actions);
    return map.containsKey('grade') ? people.firstWhere((person) => person.grade == map['grade']) : null;
  }

  Future<Map<String, dynamic>> downloadRoster() async {
    Map<String, dynamic> map = await _databaseService.getRoster();
    _save();
    return map;
  }

  getTardyTime() {
    TimeOfDay time = _databaseService.getConfig().startTime;
    tardyTime = time.replacing(minute: time.minute + 10);
  }

  List<Person> findPeople(String role, String name, TimeOfDay now) {
    List<Person> p = [];
    if(roster[role].containsKey('people') && roster[role]['people'].contains(name)) {
      p.add(new Person(role: role, name: name, time: now, tardyTime: tardyTime));
    } else {
      List<String> grades = roster[role].keys.toList().cast<String>();
      grades.forEach((grade) {
        if(roster[role][grade].contains(name)) {
          p.add(new Person(role: role, name: name, grade: grade, time: now, tardyTime: tardyTime));
        }
      });
    }
    return p;
  }

  sendToDatabase(Person p) {
    String currDate = toDbDate(DateTime.now());
    List<String> databaseRef = [];
    if(p.grade != null) {
      databaseRef.addAll(['Dates', getSchoolYear(dt: DateTime.now()), currDate, p.role, p.grade, p.name]);
    } else {
      databaseRef.addAll(['Dates', getSchoolYear(dt: DateTime.now()), currDate, p.role, p.name]);
    }
    _databaseService.set(databaseRef, val: p.toDbObj());
  }

  Future<void> _read() async {
    try {
      ReConfig config = _databaseService.getConfig();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${config.toFileString()}');
      String text = await file.readAsString();
      setState(() {
        roster = jsonDecode(text);
        loading = false;
      });
    } catch (e) {
      Map<String, dynamic> map = await downloadRoster();
      if(map.isNotEmpty) {
        setState(() {
          roster = map;
          loading = false;
        });
      }
      else {
        setState(() => loading = false);
        showAckDialog(context, 'Alert',
            'Please Tap Download Roster at the Top Left before Scanning');
      }
    }
  }

  void _save() async {
      ReConfig config = _databaseService.getConfig();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${config.toFileString()}');
      String text = jsonEncode(roster);
      file.writeAsString(text);
  }
}
