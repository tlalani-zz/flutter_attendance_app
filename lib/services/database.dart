import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/auth.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/ReConfig.dart';
import 'package:flutter_attendance/shared/constants/http-constants.dart';

class DatabaseService {
  final AuthService _auth = new AuthService();

  get currentShift => _auth.currentConfig.re_shift;

  get centers => _auth.perms.keys.cast<String>().toList();

  get classes => (String re_center) => _auth.perms[re_center].keys.cast<String>().toList();

  get shifts => (String re_center, String re_class) {
    List<String> shifts = [];
    (_auth.perms[re_center][re_class] as Map).forEach((key, val) => shifts.add('$key, ${val[0]}'));
    return shifts;
  };

  Future<Map<dynamic, dynamic>> getRoster({DateTime dt}) async {
    try {
      DateTime date = dt == null ? DateTime.now() : dt;
      String schoolYear = getSchoolYear(dt: date);
      return await HttpConstants.getRoster(schoolYear);
    } catch (e) {
      return new Map();
    }
  }

  Future<Map<String, String>> checkAllShiftsForPerson(
      String role, String name, TimeOfDay tardyTime) async {
    String schoolYear = getSchoolYear(dt: DateTime.now());
    Map<dynamic, dynamic> map = await HttpConstants.getAllStudentsFromAllShifts();
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
    String schoolYear = getSchoolYear(dt: DateTime.now());
    await HttpConstants.updateRoster(schoolYear, role, grade: grade, val: updatedRosterList);
  }

  Future<void> updateAttendance(String schoolYear, String dateString, String role, String name, {String grade, dynamic val}) async {
    await HttpConstants.updateAttendance(schoolYear, dateString, role, name, grade: grade, val: val);
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
    String schoolYear = getSchoolYear(dt: date);
    String dateString = getDateString(date);
    Map<dynamic, dynamic> map = await HttpConstants.getAttendance(schoolYear, dateString);
    if (map == null) {
      return null;
    }
    roster.forEach((role, rosterRoleMap) {
      retMap.putIfAbsent(role, () => new Map());
      if (rosterRoleMap.containsKey('people')) {
        int index = -1;
        retMap[role].putIfAbsent('people', () => new List());
        (rosterRoleMap['people'] as List).forEach((person) {
          if(map[role] == null) {
            retMap[role]['people'].add(new Person(
                role: role, name: person, status: Status.A));
          } else if ((index = contains(map[role]["people"] as List, person)) == -1) {
            retMap[role]['people']
                .add(new Person(role: role, name: person, status: Status.A));
          } else {
            retMap[role]['people']
                .add(Person.fromMapItem(map[role]['people'][index], person, role));
          }
        });
      } else {
        (rosterRoleMap as Map).keys.forEach((grade) {
          retMap[role].putIfAbsent(grade, () => new List());
          (rosterRoleMap[grade] as List).forEach((person) {
            if (person != null) {
              int index = -1;
              if (!map[role].containsKey(grade)) {
                retMap[role][grade].add(new Person(
                    role: role, grade: grade, name: person, status: Status.A));
              } else if ((index = contains((map[role][grade] as List), person)) == -1) {
                retMap[role][grade].add(new Person(
                    role: role, grade: grade, name: person, status: Status.A));
              } else {
                retMap[role][grade].add(
                    Person.fromMapItem(map[role][grade][index], person, role));
              }
            }
          });
        });
      }
    });
    return retMap;
  }

  setConfig(ReConfig config) {
    _auth.currentConfig = config;
    return getConfig();
  }

  ReConfig getConfig() {
    return _auth.currentConfig;
  }

  int contains(List<dynamic> people, String name) {
    for(int i = 0;i<people.length;i++) {
      if(people[i]["Name"] == name) return i;
    }
    return -1;
  }
}
