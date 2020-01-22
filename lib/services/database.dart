
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_attendance/services/auth.dart';
import 'package:flutter_attendance/shared/constants.dart';
import 'package:flutter_attendance/shared/currentconfig.dart';

class DatabaseService {

  final DatabaseReference _database = new FirebaseDatabase().reference();
  final AuthService _auth = new AuthService();

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
      print(e);
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
      print(e);
    }
  }

  Future<Map<dynamic, dynamic>> getCenters() async {
    try{
      DataSnapshot snapshot = await _get(['users', _auth.currentUserId]);
      Map<dynamic, dynamic> map = snapshot.value;
      map = map['permissions'];
      return map;
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<Map<dynamic, dynamic>> getRoster() async {
      try {
        String schoolYear = getSchoolYear(dt: DateTime.now());
        DataSnapshot snapshot = await get(["People", schoolYear]);
        parseRoster(snapshot.value);
      } catch (e) {
        print(e);
        return null;
      }
  }

  Map<String, dynamic> parseRoster(Map<dynamic, dynamic> map) {
    Map<String, dynamic> retMap = new Map();
    print("RosterFull: ${map}");
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
      print(e);
      return null;
    }
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