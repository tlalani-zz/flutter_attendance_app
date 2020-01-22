import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'cusom-text-field.dart';

const logoPicture = 'https://firebasestorage.googleapis.com/v0/b/attendance-rec.appspot.com/o/pictures%2Flogo.png?alt=media';
const shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
const Grades = {
  'PrePrimary': ["PK", "KG"],
  'Primary': [
    "1st Grade",
    "2nd Grade",
    "3rd Grade",
    "4th Grade",
    "5th Grade",
    "6th Grade"
  ],
  'Secondary': [
    "7th Grade",
    "8th Grade",
    "9th Grade",
    "10th Grade",
    "11th Grade",
    "12th Grade"
  ]
};
const Roles = ['Management', 'Student', 'Teacher', 'TA', 'Intern'];
const REGISTER_URL = 'https://attendance-rec.web.app/reset?mode=register';
const RESET_URL = 'https://attendance-rec.web.app/reset?mode=forgotPasssword';

String getSchoolYear({String date, DateTime dt}) {
  int month;
  int year;
  if(date != null) {
    /*  ['Aug 24', '2019']  */
    List<String> dates = date.split(", ");
    /*  ['Aug', '24'] --> indexOf('Aug') = 7 + 1 = 8 */
    month = shortMonths.indexOf(dates[0].split(" ")[0]) + 1;
    year = int.parse(dates[1]);
  } else {
    month = dt.month;
    year = dt.year;
  }
  /* After June is next school year */
  if(month > 6) {
    return year.toString() + '-' + (year+1).toString();
  } else {
    /* Before June is previous school year */
    return (year-1).toString() + '-' + year.toString();
  }
}

String toDbDate(DateTime dt) {
  String month = shortMonths[dt.month - 1];
  return '$month ${dt.day}, ${dt.year}';
}

String toDbTime(TimeOfDay td) {
  int hr = td.hour % 12 == 0 ? 12 : td.hour % 12;
  String hour = hr < 10 ? '0$hr' : '$hr';
  String minute = td.minute < 10 ? '0${td.minute}' : '${td.minute}';
  return '$hour:$minute ${td.period.toString().split(".")[1].toUpperCase()}';
}

final InputDecoration decoration = InputDecoration(
    labelText: '',
    filled: true,
    fillColor: Colors.grey[50],
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal[600])
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey)
  )
);

Future<bool> connectedToInternet() async {
  return await (Connectivity().checkConnectivity()) == ConnectivityResult.none ? false : true;
}

Future<dynamic> customDialog(BuildContext context, String title, Widget content, List<Widget> actions) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title'),
          content: content,
          actions: actions
        );
      });
}

Future<bool> showConfirmDialog(BuildContext context, String content) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
            FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                })
          ],
        );
      });
}

Future<bool> showAckDialog(BuildContext context, String title, String content) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      });
}

Future<void> showTextFieldDialog(BuildContext context, String title, Function onChanged, Function onPressed, {String labelText}) async {
  Widget content =
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget> [
      CustomTextField(labelText: labelText, onChanged: onChanged),
    ],
  );
  List<Widget> action = [
    OutlineButton(onPressed: onPressed, child: Text('Submit'))
  ];
  await customDialog(context, title, content, action);
}

Map<String, int> reasons = {
  'Extracurricular Education': 1,
  'Extracurricular Sports': 2,
  'Health': 3,
  'Personal': 4,
  'Transportation': 5,
  'Traveling': 6,
  'Did Not Call': 7,
  'No Response': 8,
  'Bad Contact Number': 9,
  'Other': 0,
};

TimeOfDay stringToTimeOfDay(String time) {
  List<String> times = time.split(":");
  return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
}

DateTime timeOfDayToDateTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);
}


/// Checks if first time is before second time
/// i.e isBefore(TimeOfDay(12:00), TimeOfDay(13:45)),
///     returns true
bool isBefore(TimeOfDay t1, TimeOfDay t2) {
  return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute < t2.minute);
}

bool isAfter(TimeOfDay t1, TimeOfDay t2) {
  return !isBefore(t1, t2);
}

enum Status {
  T, P, A, E
}

String statusToString(Status s) {
  return s.toString().split(".")[1];
}
