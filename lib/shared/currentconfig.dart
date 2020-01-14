import 'package:flutter/material.dart';

import 'constants.dart';

class ReConfig {

  String re_center;
  String re_class;
  String re_shift;

  String get day => re_shift.split(", ")[0];
  String get time => re_shift.split(", ")[1];
  String get stringStartTime => re_shift.split(", ")[1].split("-")[0];
  String get stringEndTime => re_shift.split(", ")[1].split("-")[1];
  TimeOfDay get shiftStartTime => stringToTimeOfDay(this.stringStartTime);
  TimeOfDay get shiftEndTime => stringToTimeOfDay(this.stringEndTime);

  DateTime shiftStartOnDate(DateTime date) { return timeOfDayToDateTime(date, stringToTimeOfDay(this.stringStartTime)); }
  DateTime shiftEndOnDate(DateTime date) { return timeOfDayToDateTime(date, stringToTimeOfDay(this.stringEndTime)); }

  List<String> toArray() {
    return [re_center, re_class, re_shift];
  }

  List<String> toDbRef() {
    List<String> shift = re_shift.split(", ");
    return ["REC", re_center, re_class, "Shifts", shift[0], shift[1]];
  }

  String toFileString() {
    String shift = this.re_shift.split(", ").join("@");
    return "roster#" + this.re_center + "#"+this.re_class + "#" + shift + ".json";
  }

  List<String> getGrades() {
    print(this.re_class);
    print(Grades[this.re_class]);
    return Grades[this.re_class];
  }
}