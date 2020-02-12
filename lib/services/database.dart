import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/auth.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';

class DatabaseService {
  final DatabaseReference _database = new FirebaseDatabase().reference();
  final AuthService _auth = new AuthService();

  get currentShift {
    return getConfig().re_shift;
  }

  Future<DataSnapshot> _get(List<String> path) async {
    try {
      DatabaseReference ref = _database;
      for (String pathVar in path) {
        ref = ref.child(pathVar);
      }
      return await ref.once();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<DataSnapshot> get(List<String> pathRef) async {
    List<String> path = getConfig().toDbRef();
    path.addAll(pathRef);
    return await _get(path);
  }

  Future<void> _set(List<String> path, {dynamic val}) async {
    try {
      DatabaseReference ref = _database;
      for (String pathVar in path) {
        ref = ref.child(pathVar);
      }
      await ref.set(val);
    } catch (e) {
      print(e);
    }
  }

  Future<void> set(List<String> pathRef, {dynamic val}) async {
    List<String> path = getConfig().toDbRef();
    path.addAll(pathRef);
    return await _set(path, val: val);
  }

  Future<void> remove(List<String> path) async {
    try {
      DatabaseReference ref = _database;
      for (String pathVar in path) {
        ref = ref.child(pathVar);
      }
      await ref.remove();
    } catch (e) {}
  }

  Future<Map<dynamic, dynamic>> getCenters() async {
    try {
      DataSnapshot snapshot = await _get(['users', _auth.currentUserId]);
      Map<dynamic, dynamic> map = snapshot.value;
      map = map['permissions'];
      return map;
    } catch (e) {
      return null;
    }
  }

  Future<Map<dynamic, dynamic>> getRoster() async {
    try {
      String schoolYear = getSchoolYear(dt: DateTime.now());
      DataSnapshot snapshot = await get(["People", schoolYear]);
      return parseRoster(snapshot.value);
    } catch (e) {
      return new Map();
    }
  }

  Map<String, dynamic> parseRoster(Map<dynamic, dynamic> map) {
    Map<String, dynamic> retMap = new Map();
    try {
      List<String> roles = map.keys.toList().cast<String>();
      roles.forEach((role) {
        retMap.putIfAbsent(role, () => new Map<String, dynamic>());
        if (map[role] is Map) {
          Map<dynamic, dynamic> grades = map[role];
          grades.keys.toList().cast<String>().forEach((grade) {
            List<dynamic> people = map[role][grade];
            retMap[role].putIfAbsent(grade, () => people);
          });
        } else {
          List<dynamic> people = map[role];
          retMap[role].putIfAbsent('people', () => people);
        }
      });
      return retMap;
    } catch (e) {
      return new Map();
    }
  }

  Future<Map<String, String>> checkAllShiftsForPerson(
      String role, String name, TimeOfDay tardyTime) async {
    String schoolYear = getSchoolYear(dt: DateTime.now());
    List<String> list = getConfig().toDbRef().sublist(0, 4);
    Map<dynamic, dynamic> map = (await this._get(list)).value;
    for (var shiftDay in map.keys) {
      for (var shiftTime in map[shiftDay].keys) {
        dynamic roles = map[shiftDay][shiftTime]["People"][schoolYear][role];
        if (roles is Map) {
          for (var grade in roles.keys) {
            if (roles[grade].contains(name))
              return {
                'shiftDay': shiftDay,
                'shiftTime': shiftTime,
                'grade': grade,
                'name': name,
                'role': role
              };
          }
        }
      }
    }
    return null;
  }

  Future<void> updateRoster(List<String> updatedRosterList, String role,
      {String grade}) async {
    var path = ['People', getSchoolYear(dt: DateTime.now()), role];
    if (grade != null) path.add(grade);
    this.set(path, val: updatedRosterList);
  }

  bool isGrade(String key, ReConfig config) {
    return Grades[config.re_class].contains(key);
  }

  Future<Map<String, Map<String, List<Person>>>> getAttendance(
      {DateTime dt}) async {
    Map<String, Map<String, List<Person>>> retMap = new Map();
    Map<dynamic, dynamic> roster = await getRoster();
    DateTime date =
        (dt == null ? getLastShiftDay(getConfig(), DateTime.now()) : dt);
    print(date);
    String schoolYear = getSchoolYear(dt: date);
    String dateString =
        '${shortMonths[date.month - 1]} ${date.day}, ${date.year}';
    DataSnapshot snapshot = await get(["Dates", schoolYear, dateString]);
    Map<dynamic, dynamic> map = snapshot.value;
    if (map == null) {
      return null;
    }
    roster.forEach((role, rosterRoleMap) {
      retMap.putIfAbsent(role, () => new Map());
      if (rosterRoleMap.containsKey('people')) {
        retMap[role].putIfAbsent('people', () => new List());
        (rosterRoleMap['people'] as List).forEach((person) {
          if (!(map[role] as Map).keys.contains(person)) {
            retMap[role]['people']
                .add(new Person(role: role, name: person, status: Status.A));
          } else {
            retMap[role]['people']
                .add(Person.fromMapItem(map[role][person], person, role));
          }
        });
      } else {
        (rosterRoleMap as Map).keys.forEach((grade) {
          retMap[role].putIfAbsent(grade, () => new List());
          (rosterRoleMap[grade] as List).forEach((person) {
            if (person != null) {
              if (!map[role].containsKey(grade)) {
                retMap[role][grade].add(new Person(
                    role: role, grade: grade, name: person, status: Status.A));
              } else if (!(map[role][grade] as Map).keys.contains(person)) {
                retMap[role][grade].add(new Person(
                    role: role, grade: grade, name: person, status: Status.A));
              } else {
                retMap[role][grade].add(
                    Person.fromMapItem(map[role][grade][person], person, role));
              }
            }
          });
        });
      }
    });
    return retMap;
  }

  setConfig(config) {
    _auth.setConfig(config);
  }

  ReConfig getConfig() {
    return _auth.currentConfig;
  }
}
