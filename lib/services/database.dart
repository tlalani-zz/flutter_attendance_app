
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attendance/services/auth.dart';
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
      for(String pathVar in path) {
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

  Future<void> set(List<String> path, {dynamic val} ) async {
    try {
      DatabaseReference ref = _database;
      for(String pathVar in path) {
        ref = ref.child(pathVar);
      }
      await ref.set(val);
    } catch (e) {
    }
  }

  Future<void> remove(List<String> path) async {
    try {
      DatabaseReference ref = _database;
      for(String pathVar in path) {
        ref = ref.child(pathVar);
      }
      await ref.remove();
    } catch (e) {
    }
  }

  Future<Map<dynamic, dynamic>> getCenters() async {
    try{
      DataSnapshot snapshot = await _get(['users', _auth.currentUserId]);
      Map<dynamic, dynamic> map = snapshot.value;
      map = map['permissions'];
      return map;
    } catch(e) {
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
        if(map[role] is Map) {
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

  Future<Map<String, String>> checkAllShiftsForPerson(String role, String name, TimeOfDay tardyTime) async {
    String schoolYear = getSchoolYear(dt: DateTime.now());
    List<String> list = getConfig().toDbRef().sublist(0, 4);
    Map<dynamic, dynamic> map = (await this._get(list)).value;
    for(var shiftDay in map.keys) {
      for(var shiftTime in map[shiftDay].keys) {
        dynamic roles = map[shiftDay][shiftTime]["People"][schoolYear][role];
        if(roles is Map) {
          for(var grade in roles.keys) {
            if(roles[grade].contains(name))
                return {'shiftDay': shiftDay, 'shiftTime': shiftTime, 'grade': grade, 'name': name, 'role': role };
          }
        }
      }
    }
    return null;
  }

  bool isGrade(String key, ReConfig config) {
    return Grades[config.re_class].contains(key);
  }


  setConfig(config) {
    _auth.setConfig(config);
  }

  ReConfig getConfig() {
    return _auth.currentConfig;
  }
}