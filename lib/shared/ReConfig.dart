import 'package:flutter/material.dart';

import 'constants.dart';

class ReConfig {

  String re_center;
  String re_class;
  String re_shift;

  String get day => re_shift.split(", ")[0];
  String get time => re_shift.split(", ")[1];
  String get s_startTime => time.split("-")[0];
  String get s_endTime => time.split("-")[1];
  TimeOfDay get startTime => stringToTimeOfDay(s_startTime);
  TimeOfDay get endTime => stringToTimeOfDay(s_endTime);
  TimeOfDay get earliestStartTime => startTime.replacing(hour: startTime.hour - 2);
  TimeOfDay get latestEndTime => endTime.replacing(hour: endTime.hour + 2);
  /// Returns [{center}, {class}, {shifts}]
  List<String> get asArray => [re_center, re_class, re_shift];
  DateTime shiftStartOnDate(DateTime date) { return timeOfDayToDateTime(date, startTime); }
  DateTime shiftEndOnDate(DateTime date) { return timeOfDayToDateTime(date, endTime); }

  /// Returns REC/{center}/{class}/Shifts/{day}/{time}
  List<String> toDbRef() {
    return ["REC", re_center, re_class, "Shifts", day, time];
  }

  String toFileString() {
    return "roster#" + this.re_center + "#"+this.re_class + "#" + day + "@" + time + ".json";
  }

  List<String> getGrades() {
    return Grades[this.re_class];
  }
}