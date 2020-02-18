import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/Person.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';

class AttendanceTabbedPage extends StatelessWidget {
  final Map<String, List<Person>> map;
  final String role;
  final Function onUpdated;

  const AttendanceTabbedPage(this.map, this.role, this.onUpdated);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: map.containsKey('people')
            ? map['people'].length > 0
                ? ListView(
                    children: makeList(context, map['people'], role),
                  )
                : null
            : ListView.builder(
                itemCount: mapSize(),
                itemBuilder: (context, index) {
                  return ExpansionTile(
                      title: Text(getKey(index)),
                      children: <Widget>[
                        Column(children: _buildExpandableList(context, index))
                      ],
                      trailing: _anyoneHasAbsentWithNoReason(index)
                          ? Icon(Icons.error, color: Colors.redAccent)
                          : null);
                }));
  }

  String getKey(int index) {
    return map.keys.toList()[index];
  }

  int mapSize() {
    return map.keys.toList().length;
  }

  List<Widget> _buildExpandableList(BuildContext context, int index) {
    List<Person> list = map[getKey(index)];
    return list.length > 0
        ? makeList(context, list, role, grade: getKey(index))
        : new List();
  }

  bool _anyoneHasAbsentWithNoReason(int index) {
    Person p = map[getKey(index)].firstWhere(
        (Person item) => item.shouldHaveStatus && item.reason == null,
        orElse: () => null);
    return p != null;
  }

  makeList(BuildContext context, List<Person> list, String role,
      {String grade}) {
    return list.map((Person person) {
      return listTile(context, person);
    }).toList();
  }

  Widget listTile(BuildContext context, Person person) {
    if (person.name == null) {
      print(person);
    }
    return ListTile(
      trailing: getIcon(person),
      title: Text(person.name),
      onTap: () async {
        dynamic updatedPerson = await Navigator.pushNamed(
            context, "/updatePerson",
            arguments: person);
        onUpdated(updatedPerson);
      },
    );
  }

  Icon getIcon(Person person) {
    if (person.status == Status.A) {
      if (person.reason == null) {
        return Icon(Icons.error, color: Colors.redAccent);
      } else {
        return Icon(Icons.info, color: Colors.teal[400]);
      }
    }
    return null;
  }
}
