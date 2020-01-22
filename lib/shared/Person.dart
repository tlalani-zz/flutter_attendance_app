import 'package:flutter/material.dart';

import 'constants.dart';

class Person {
  String role;
  String name;
  String grade;
  Status status;
  String reason;
  String comments;
  TimeOfDay time;


  Person({this.role, this.name, this.time, this.grade, TimeOfDay tardyTime, this.reason, this.comments}) {
    this.status = isAfter(this.time, tardyTime) ? Status.T : Status.P;
  }

  Map<String, String> toDbObj() {
    Map<String, String> map = new Map();
    map.putIfAbsent('Status', () => statusToString(this.status));
    map.putIfAbsent('Time', () => this.parseTime());
    if(status == Status.T) {
      map.putIfAbsent('Reason', () => this.reason);
      if(comments != null) {
        map.putIfAbsent('Comments', () => this.comments);
      }
    }
    return map;
  }

  parseTime() {
    String hour = this.time.hour < 10 ? '0${this.time.hour}' : '${this.time.hour}';
    String minute = this.time.minute < 10 ? '0${this.time.minute}' : '${this.time.minute}';
    return '$hour:$minute';
  }

  @override
  String toString() {
    return 'Name: $name, Role: $role';
  }


}