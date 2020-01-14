import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';
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
    _read().then((res) {
      if(res != null) {
        roster = res;
        setState(() => loading = false);
      } else {
        setState(() => loading = false);
        showAckDialog(context, "ALERT", "The roster was unable to be found, please download the roster before scanning");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getTardyTime();
    return loading == true ? Loader() : Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_download),
            tooltip: 'Download Roster',
            onPressed: () async {
              roster = await downloadRoster();
            }
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Manual Entry',
            onPressed: () async {
              Person person = await Navigator.pushNamed(context, '/manual', arguments: tardyTime);
              sendToDatabase(person);
            }
          )
        ],
      ),
      body: Center(
        child: Container(
              child: ButtonTheme(
                minWidth: 200,
                height: 200,
                child: RaisedButton(
                  color: Colors.teal[400],
                  child: Text('SCAN', style: TextStyle(fontSize: 40, color: Colors.white)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.teal[400])
                  ),
                  onPressed: () async {
                    String res = await scanner.scan();
                    List<Person> people = findPeople(res);
                    Person p = await showDropdownConfirmDialog(context, res.split(":"), people);
                    if(p != null) {
                      if(p.status == Status.T) {
                        Map<String, String> map = await Navigator.pushNamed(context, "/tardy");
                        p.reason = map["reason"];
                        if(map.containsKey("comments")) {
                          p.comments = map["comments"];
                        }
                      }
                      sendToDatabase(p);
                    } else {
                      showAckDialog(context, "Error", "There was an error scanning your code, please try again or enter the person manually");
                    }
                  },
                ),
              ),
            )
          ),
    );
  }

  Future<Person> showDropdownConfirmDialog(BuildContext context, List<String> result, List<Person> people) async {
    List<String> grades = people.map((person) {return person.grade;}).toList();
    String grade = grades[0];
    Widget content =
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(result[0]),
        Text(result[1]),
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
        child: Text('Yes'),
        onPressed: () {
        Navigator.pop(context, {'grade': grade });
      }),
      FlatButton(
        child: Text('No'),
        onPressed: () {
        Navigator.pop(context, new Map<String, String>());
      })
    ];
    Map<String, String> map = await customDialog(context, "Confirm", content, actions);
    return map.containsKey('grade') ? people.firstWhere((person) => person.grade == map['grade']) : null;
  }

  parseResult(res) {
    return ['Role: ${res[0]}', 'Name: ${res[1]}'];
  }

  Future<Map<String, dynamic>> downloadRoster() async {
    Map<String, dynamic> map = await _databaseService.getRoster();
    _save();
    return map;
  }

  getTardyTime() {
    TimeOfDay time = _databaseService.getConfig().shiftStartTime;
    tardyTime = time.replacing(minute: time.minute + 10);
  }

  List<Person> findPeople(res) {
    String role = res.split(":")[0];
    String name = res.split(":")[1];
    List<Person> p = [];
    if(roster[role].containsKey('people')) {
      p.add(new Person(role: role, name: name, time: TimeOfDay.now(), tardyTime: tardyTime));
    } else {
      List<String> grades = roster[role].keys.toList().cast<String>();
      grades.forEach((grade) {
        if(roster[role][grade].contains(name)) {
          p.add(new Person(role: role, name: name, grade: grade, time: TimeOfDay.now(), tardyTime: tardyTime));
        }
      });
    }
    return p;
  }

  sendToDatabase(Person p) {
    String currDate = toDbDate(DateTime.now());
    List<String> dbs =_databaseService.getConfig().toDbRef();
    if(p.grade != null) {
      dbs.addAll(['Dates', getSchoolYear(dt: DateTime.now()), currDate, p.role, p.grade, p.name]);
    } else {
      dbs.addAll(['Dates', getSchoolYear(dt: DateTime.now()), currDate, p.role, p.name]);

    }
    _databaseService.set(dbs, val: p.toDbObj());
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      ReConfig config = _databaseService.getConfig();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${config.toFileString()}');
      String text = await file.readAsString();
      return jsonDecode(text);
    } catch (e) {
      return null;
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
