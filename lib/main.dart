import 'package:flutter/material.dart';
import 'package:flutter_attendance/mobile/screens/home.dart';
import 'package:flutter_attendance/mobile/screens/intro.dart';
import 'package:flutter_attendance/mobile/screens/manual.dart';
import 'package:flutter_attendance/mobile/screens/roster/roster-update.dart';
import 'package:flutter_attendance/mobile/screens/selection.dart';
import 'package:flutter_attendance/mobile/screens/signin.dart';
import 'package:flutter_attendance/mobile/screens/tardy.dart';
import 'package:flutter_attendance/mobile/screens/update/update-attendance.dart';
import 'package:flutter_attendance/mobile/screens/update/update-person.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        fontFamily: 'Roboto',
        primarySwatch: Colors.teal,
      ),
        initialRoute: "/login",
        routes: {
          "/intro": (context) => IntroScreen(),
          "/login": (context) => SignIn(),
          "/select": (context) => ReOptionsSelect(),
          "/home": (context) => Home(),
          "/tardy": (context) => TardyOptions(),
          "/manual": (context) => ManualEntry(),
          "/roster": (context) => Roster(),
          "/update": (context) => UpdateAttendance(),
          "/updatePerson": (context) => UpdatePerson(),
        }
    );
  }
}
