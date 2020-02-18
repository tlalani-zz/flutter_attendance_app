import 'dart:convert';
import 'package:flutter_attendance/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class HttpConstants {
  static final BASE_URL =
      'https://us-central1-attendance-rec.cloudfunctions.net/app';
  static AuthService _auth = new AuthService();

  static String get perms => _auth.currentConfig.asArray.toString();

  static Future<Map<dynamic, dynamic>> getPermissions() async {
    Response res = await http.get('$BASE_URL/permissions', headers: {
      "authorization": await _auth.getUserToken(),
    });
    return json.decode(res.body)["permissions"];
  }

  static Future<Map<dynamic, dynamic>> getRoster(String schoolYear) async {
    Response res = await http.get('$BASE_URL/roster/$schoolYear',
        headers: {"authorization": await _auth.getUserToken(), "perms": perms});
    return json.decode(res.body);
  }

  static Future<Map<dynamic, dynamic>> getAttendance(
      String schoolYear, String date) async {
    Response res = await http.get('$BASE_URL/attendance/$schoolYear?date=$date',
        headers: {"authorization": await _auth.getUserToken(), "perms": perms});
    print(res.body);
    return json.decode(res.body);
  }

  static Future<Map<dynamic, dynamic>> getAllStudentsFromAllShifts() async {
    Response res = await http.get('$BASE_URL/attendance', headers: {
      "authorization": await _auth.getUserToken(),
      "perms": perms
    });
    return json.decode(res.body);
  }

  static Future<void> updateRoster(String schoolYear, String role,
      {String grade, List<String> val}) async {
    String url = grade != null
        ? '$BASE_URL/roster/$schoolYear/$role/$grade'
        : '$BASE_URL/roster/$schoolYear/$role';
    await http.put(url,
        headers: {"authorization": await _auth.getUserToken(), "perms": perms},
        body: json.encode({"people": val})
    );
  }

  static Future<void> updateAttendance(String schoolYear, String dateString, String role, String name, {String grade, Map val}) async {
    String url = grade != null
        ? '$BASE_URL/attendance/$schoolYear/$dateString/$role/$grade'
        : '$BASE_URL/attendance/$schoolYear/$dateString/$role';
    print(url);
    print('body::\n');
    print(json.encode({"name": name, "person": val}));
    print(perms);
    await http.post(url,
        headers: {"authorization": await _auth.getUserToken(), "perms": perms, "content-type":"application/json"},
        body: json.encode({"name": name, "person": val})
    );
  }
}
