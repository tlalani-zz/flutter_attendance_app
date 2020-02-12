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

  Person(
      {this.role,
      this.name,
      this.time,
      this.grade,
      TimeOfDay tardyTime,
      this.reason,
      this.comments,
      this.status}) {
    this.status = (this.status == null
        ? (this.time != null
            ? (isAfter(this.time, tardyTime) ? Status.T : Status.P)
            : null)
        : this.status);
  }

  get shouldHaveStatus => (this.status == Status.E ||
      this.status == Status.T ||
      this.status == Status.A);
  get shouldNotHaveStatus => !this.shouldHaveStatus;

  Map<String, String> toDbObj() {
    Map<String, String> map = new Map();
    map.putIfAbsent('Status', () => statusToString(this.status));
    map.putIfAbsent('Time', () => this.parseTime());
    if (status == Status.T) {
      map.putIfAbsent('Reason', () => this.reason);
      if (comments != null) {
        map.putIfAbsent('Comments', () => this.comments);
      }
    }
    return map;
  }

  parseTime() {
    String hour =
        this.time.hour < 10 ? '0${this.time.hour}' : '${this.time.hour}';
    String minute =
        this.time.minute < 10 ? '0${this.time.minute}' : '${this.time.minute}';
    return '$hour:$minute';
  }

  @override
  String toString() {
    return grade != null
        ? '{Name: $name, Role: $role, Grade: $grade, Status: $status, Reason: $reason}'
        : '{Name: $name, Role: $role, Status: $status, Reason: $reason}';
  }

  bool equals(Person other) {
    return this.role == other.role || this.name == other.name;
  }

  static Person fromMapItem(Map map, String name, String role) {
    Person p = new Person();
    p.status = map.containsKey('Status') ? stringToStatus(map['Status']) : null;
    p.time = map.containsKey('Time') ? stringToTimeOfDay(map['Time']) : null;
    p.reason = map.containsKey('Reason') ? map['Reason'] : null;
    p.comments = map.containsKey('Comments') ? map['Comments'] : null;
    p.role = role;
    p.name = name;
    return p;
  }
}
