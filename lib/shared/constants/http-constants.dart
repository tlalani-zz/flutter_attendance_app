import 'dart:convert';
import 'package:flutter_attendance/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'constants.dart';

class HttpConstants {
  static const String BASE_URL =
        'https://us-central1-attendance-rec.cloudfunctions.net/app';
       // 'http://10.0.2.2:5000/attendance-rec/us-central1/app';
  static AuthService _auth = new AuthService();

  //GETTERS//
  static String get perms => json.encode(_auth.currentConfig.toMap());

  static Future<Map<dynamic, dynamic>> getPermissions() async {
    Response res = await http.get('$BASE_URL/permissions', headers: {
      "authorization": await _auth.getUserToken(),
    });
    return json.decode(res.body)["permissions"];
  }

  static Future<Map<dynamic, dynamic>> getRoster(String schoolYear) async {
    return await _makeRequest('roster/$schoolYear', RequestType.GETTER);
  }

  static Future<Map<dynamic, dynamic>> getAttendance(
      String schoolYear, String date) async {
    return await _makeRequest('attendance/$schoolYear?date=$date', RequestType.GETTER);
  }

  static Future<Map<dynamic, dynamic>> getAllStudentsFromAllShifts() async {
    return await _makeRequest('attendance', RequestType.GETTER);
  }

  //SETTERS//
  static Future<void> updateRoster(String schoolYear, String role,
      {String grade, List<String> val}) async {
    return await _makeRequest('roster/$schoolYear/$role/${grade == null ? '' : grade}', RequestType.SETTER, body: {"people": val});
  }

  static Future<void> updateAttendance(String schoolYear, String dateString, String role, String name,
      {String grade, Map val}) async {
    return await _makeRequest(
        'attendance/$schoolYear/$dateString/$role/${grade == null ? '' : grade}', RequestType.SETTER, body: {"name": name, "person": val}
    );
  }

  static Future<dynamic> _makeRequest(String url, RequestType type, {dynamic body, dynamic headers}) async {
    url = '$BASE_URL/$url';
    print(url);
    if(headers == null) {
      headers = {"authorization": await _auth.getUserToken(), "perms": perms};
    }
    if (type == RequestType.GETTER) {
      try {
        Response res = await http.get(url, headers: headers);
        return json.decode(res.body);
      } catch(e) {
        return null;
      }
    } else {
      try {
        await http.post(
            url, headers: headers, body: json.encode(body));
        return null;
      } catch(e) {
        print(e);
        return e;
      }
    }
  }
}
