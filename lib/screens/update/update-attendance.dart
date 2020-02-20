import 'package:flutter/material.dart';
import 'package:flutter_attendance/screens/update/attendance-tabbed-page.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/loader.dart';
import 'package:page_view_indicators/arrow_page_indicator.dart';

class UpdateAttendance extends StatefulWidget {
  @override
  _UpdateAttendanceState createState() => _UpdateAttendanceState();
}

class _UpdateAttendanceState extends State<UpdateAttendance> {
  DatabaseService _databaseService = new DatabaseService();
  PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.9);
  final _currentPageNotifier = ValueNotifier<int>(0);
  Map<String, Map<String, List<Person>>> map;
  bool loading = true;
  String title = "Update";
  List<Widget> views;
  DateTime date;

  @override
  void initState() {
    date = getLastShiftDay(_databaseService.getConfig(), DateTime.now());
    print(date);
    _databaseService.getAttendance(dt: date).then((res) {
      if (res != null) {
        map = res;
        setState(() => views = updateViews());
        setState(() {
          loading = false;
          title = 'Update ${map.keys.toList()[0]}';
        });
      } else {
        map = null;
        setState(() {
          loading = false;
        });
        showAckDialog(context, 'ERROR',
            'Unable to find attendance data for the current day');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.date_range),
                tooltip: 'Change Date',
                onPressed: () async {
                  DateTime day = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now());
                  if(day != null) {
                    setState(() {
                      date = day;
                      loading = true;
                    });
                    map = await _databaseService.getAttendance(dt: date);
                    if(map != null) {
                      setState(() {
                        views = updateViews();
                        loading = false;
                      });
                    } else {
                      setState(() {
                        loading = false;
                      });
                      showAckDialog(context, 'ERROR',
                          'Unable to find attendance data for the current day');
                    }
                  }
                })
          ],
        ),
        body: loading == true
            ? Loader()
            : map == null
                ? null
                : ArrowPageIndicator(
                    pageController: _pageController,
                    itemCount: map.keys.length,
                    currentPageNotifier: _currentPageNotifier,
                    iconSize: 24,
                    isInside: true,
                    child: PageView(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: (page) {
                        _currentPageNotifier.value = page;
                        setState(() {
                          title = map.keys.toList()[page];
                        });
                      },
                      children: views != null ? views : null,
                    ),
                  ));
  }

  updateViews() {
    return map.keys
        .cast<String>()
        .toList()
        .map((role) => Card(
            elevation: 4,
            child: AttendanceTabbedPage(map[role], role, updatePerson)))
        .toList();
  }

  updatePerson(Person person) {
    if(person != null) {
      person.time = person.isTardy
          ? _databaseService
          .getConfig()
          .tardyTime
          : _databaseService
          .getConfig()
          .startTime;
      print('$person + ${person.time}');
      String schoolYear = getSchoolYear(dt: date);
      String dateString = getDateString(date);
      this._databaseService.updateAttendance(
          schoolYear, dateString, person.Role, person.Name, grade: person.Grade,
          val: person.toDbObj());
      setState(() => views = updateViews());

    }
  }
}
