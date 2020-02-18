import 'package:flutter/material.dart';
import 'package:flutter_attendance/screens/roster/tabbed-page.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';
import 'package:flutter_attendance/shared/loader.dart';
import 'package:page_view_indicators/arrow_page_indicator.dart';

class Roster extends StatefulWidget {
  @override
  _RosterState createState() => _RosterState();
}

class _RosterState extends State<Roster> {
  DatabaseService _databaseService = new DatabaseService();
  PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.9);
  final _currentPageNotifier = ValueNotifier<int>(0);
  Map<dynamic, dynamic> map;
  bool loading = true;
  String title = "Roster";
  List<Widget> views;

  @override
  void initState() {
    _databaseService.getRoster().then((res) {
      print(res);
      map = res;
      setState(() => views = updateViews());
      setState(() {
        loading = false;
        title = map.keys.toList()[0];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: loading == true
            ? Loader()
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
                      title = currentPage(page);
                    });
                  },
                  children: views,
                ),
              ));
  }

  String currentPage(page) {
    return map.keys.toList()[page];
  }

  updateViews() {
    return map.keys
        .cast<String>()
        .toList()
        .map((role) => Card(
            elevation: 4,
            child: TabbedPage(map[role], role,
                onAdded: onPersonAdded, onDeleted: onPersonDeleted)))
        .toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  void onPersonAdded(String role, String name, {String grade}) {
    List<String> updatedRoster;
    if (grade != null) {
      updatedRoster = List<String>.from(map[role][grade]);
      updatedRoster.add(name);
      print(updatedRoster);
      try {
        _databaseService.updateRoster(updatedRoster, role, grade: grade);
        map[role][grade] = updatedRoster;
      } catch (e) {
        showAckDialog(context, 'Error', 'We were unable to save your changes.');
      }
    } else {
      updatedRoster = List<String>.from(map[role]['people']);
      updatedRoster.add(name);
      try {
        _databaseService.updateRoster(updatedRoster, role);
        map[role]['people'] = updatedRoster;
      } catch (e) {
        showAckDialog(context, 'Error', 'We were unable to save your changes.');
      }
    }
    setState(() => views = updateViews());
  }

  void onPersonDeleted(String role, String name, {String grade}) {
    if (grade != null) {
      List<String> updatedRoster = List<String>.from(map[role][grade]);
      updatedRoster.remove(name);
      try {
        _databaseService.updateRoster(updatedRoster, role, grade: grade);
        map[role][grade] = updatedRoster;
      } catch (e) {
        showAckDialog(context, 'Error', 'We were unable to save your changes.');
      }
    } else {
      List<String> updatedRoster = List<String>.from(map[role]['people']);
      updatedRoster.remove(name);
      try {
        _databaseService.updateRoster(updatedRoster, role);
        map[role][grade] = updatedRoster;
      } catch (e) {
        showAckDialog(context, 'Error', 'We were unable to save your changes.');
      }
    }
    setState(() => views = updateViews());
  }
}
