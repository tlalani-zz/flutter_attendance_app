import 'package:flutter/material.dart';

import 'constants/constants.dart';

class Person {
  String Role;
  String Name;
  String Grade;
  StatusType Status;
  String Reason;
  String Comments;
  TimeOfDay time;

  Person(
      {this.Role,
      this.Name,
      this.time,
      this.Grade,
      TimeOfDay tardyTime,
      this.Reason,
      this.Comments,
      this.Status}) {
    this.Status = (this.Status == null
        ? (this.time != null
            ? (isAfter(this.time, tardyTime) ? StatusType.T : StatusType.P)
            : null)
        : this.Status);
  }

  get shouldHaveStatus => (this.Status == StatusType.E ||
      this.Status == StatusType.T ||
      this.Status == StatusType.A);
  get shouldNotHaveStatus => !this.shouldHaveStatus;

  get isPresent => (this.Status == StatusType.T || this.Status == StatusType.P);
  get isTardy => this.Status == StatusType.T;
  get isNotTardy => this.Status == StatusType.P;
  get isAbsent => this.Status == StatusType.E || this.Status == StatusType.A;
  get isNotAbsent => !this.isAbsent;

  Map<String, String> toDbObj() {
    Map<String, String> map = new Map();
    map.putIfAbsent('Status', () => statusToString(this.Status));
    if(this.isNotAbsent) {
      map.putIfAbsent('Time', () => this.parseTime());
    }
    if (this.shouldHaveStatus) {
      map.putIfAbsent('Reason', () => this.Reason);
      if (Comments != null) {
        map.putIfAbsent('Comments', () => this.Comments);
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
    return Grade != null
        ? '{Name: $Name, Role: $Role, Grade: $Grade, Status: $Status, Reason: $Reason}'
        : '{Name: $Name, Role: $Role, Status: $Status, Reason: $Reason}';
  }

  bool equals(Person other) {
    return this.Role == other.Role || this.Name == other.Name;
  }

  static Person fromMapItem(Map map, {String Name, String Role}) {
    Person p = new Person();
    p.Status = map.containsKey('Status') ? stringToStatus(map['Status']) : null;
    p.time = map.containsKey('Time') ? stringToTimeOfDay(map['Time']) : null;
    p.Reason = map.containsKey('Reason') ? map['Reason'] : null;
    p.Comments = map.containsKey('Comments') ? map['Comments'] : null;
    p.Role = map.containsKey('Role') ? map['Role'] : Role;
    p.Name = map.containsKey('Name') ? map['Name'] : Name;
    return p;
  }
}
