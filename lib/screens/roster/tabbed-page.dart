import 'package:flutter/material.dart';
import 'package:flutter_attendance/shared/constants/constants.dart';

class TabbedPage extends StatelessWidget {
  final Map<dynamic, dynamic> map;
  final String role;
  final Function onDeleted;
  final Function onAdded;
  const TabbedPage(this.map, this.role, {this.onDeleted, this.onAdded});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: map.containsKey('people')
            ? map['people'].length > 0
                ? ListView(
                    children: makeList(map['people'], context, role),
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
        ? makeList(list, context, role, grade: getKey(index))
        : new List();
  }

  List<Widget> makeList(List list, BuildContext context, String role,
      {String grade}) {
    List<Widget> newList = list.map((name) {
      return name != null
          ? grade != null
              ? personListTile(role, name, context, destination: grade)
              : personListTile(role, name, context)
          : SizedBox(height: 0);
    }).toList();
    if (grade != null) {
      newList.add(addNewListTile(context, destination: grade));
    } else {
      newList.add(addNewListTile(context));
    }
    return newList;
  }

  Widget personListTile(
    String role,
    String name,
    BuildContext context,
  {String destination}
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
            leading: IconButton(
                icon: Container(
                    child: Image(
                        image: AssetImage('images/qr-icon.png'),
                        fit: BoxFit.scaleDown)),
                onPressed: () async {
                  await showCodeDialog(context, role, name);
                }),
            trailing: onDeleted == null
                ? null
                : IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  bool res = await showConfirmDialog(
                      context, 'Are you sure you want to delete $name?');
                  if (res == true) {
                    destination != null ? onDeleted(role, name, grade: destination) : onDeleted(role, name);
                  }
                }),
            title: Text(name)),
        Divider(),
      ],
    );
  }

  Widget addNewListTile(BuildContext context, {String destination}) {
    String name = "";
    return ListTile(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth - 50,
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(hintText: 'Add New'),
                        onChanged: (val) {
                          name = val;
                        }),
                  ),
                ],
              ),
            );
          }),
        ),
        trailing: onAdded == null
            ? null
            :IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var content =
                  'Are you sure you want to add $role "$name" to ${destination != null ? destination : "Staff"}';
              bool res = await showConfirmDialog(context, content);
              if (res == true) {
                destination != null ? onAdded(role, name, grade: destination) : onAdded(role, name);
                print("added $role, $destination, $name");
              }
            }));
  }
}
