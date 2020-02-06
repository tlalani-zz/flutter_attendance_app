import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/constants.dart';

class TabbedPage extends StatelessWidget {
  final Map<dynamic, dynamic> map;
  final String role;
  const TabbedPage(this.map, this.role);
  @override
  Widget build(BuildContext context) {
    return Card(
        child: map.containsKey('people')
            ? map['people'].length > 0
                ? ListView(
                    children: makeList(map['people'], context, role: role),
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
                  );
                }));
  }

  String getKey(int index) {
    return map.keys.toList()[index];
  }

  int mapSize() {
    return map.keys.toList().length;
  }

  List<Widget> _buildExpandableList(BuildContext context, int index) {
    List<dynamic> list = map[getKey(index)];
    return list.length > 0
        ? makeList(list, context, grade: getKey(index))
        : new List();
  }

  List<Widget> makeList(List list, BuildContext context, {String grade, String role}) {
    List<Widget> newList = list.map((name) {
      return name != null
          ? grade != null
              ? personListTile(role, name, context, inner: true)
              : personListTile(role, name, context)
          : SizedBox(height: 0);
    }).toList();
    if (grade != null) {
      newList.add(addNewListTile(context, grade));
    } else {
      newList.add(addNewListTile(context, role));
    }
    return newList;
  }

  Widget personListTile(String role, String name, BuildContext context, {bool inner = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
            leading: inner ? SizedBox() : null,
            trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  bool res = await showConfirmDialog(
                      context, 'Are you sure you want to delete $name?');
                  if (res == true) {
                    print("deleted");
                  }
                }),
            title: Text(name),
            onLongPress: () async {
              await showCodeDialog(context, role, name);
            }),
        Divider(),
      ],
    );
  }

  Widget addNewListTile(BuildContext context, String destination) {
    String name = "";
    return ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: new Container(
            width: 300,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 3,
                  child: new TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(hintText: 'Add New'),
                      onChanged: (val) {
                        name = val;
                      }),
                ),
              ],
            ),
          ),
        ),
        trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var content =
                  'Are you sure you want to add $role "$name" to $destination';
              bool res = await showConfirmDialog(context, content);
              if (res == true) {
                print("added $role, $destination, $name");
              }
            }));
  }
}
