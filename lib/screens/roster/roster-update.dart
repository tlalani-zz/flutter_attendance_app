import 'package:flutter/material.dart';
import 'package:flutter_attendance/screens/roster/tabbed-page.dart';
import 'package:flutter_attendance/services/database.dart';
import 'package:flutter_attendance/shared/loader.dart';

class Roster extends StatefulWidget {
  @override
  _RosterState createState() => _RosterState();
}

class _RosterState extends State<Roster> {
  DatabaseService _databaseService = new DatabaseService();
  PageController _pageController = PageController(initialPage: 0);
  Map<dynamic, dynamic> map;
  bool loading = true;
  String title = "Student";

  @override
  void initState() {
    _databaseService.getRoster().then((res) {
      print(res);
      map = res;
      setState(() {loading = false;});
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: loading == true ? Loader() : PageView(
        controller: _pageController,
        onPageChanged: (page) {setState(() {  title = currentPage(page);});},
        children:
          map.keys.cast<String>().toList().map((role) =>
              TabbedPage(map[role], role)
          ).toList(),
      )
    );
  }

  String currentPage(page) {
    return map.keys.toList()[page];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  onPersonAdded() {

  }

  onPersonDeleted() {

  }
}
