import 'package:flutter/material.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/home/group_list_item.dart';
import 'package:ttmm/services/database.dart';

class GroupList extends StatefulWidget {
  final List<dynamic> groupIds;

  GroupList({@required this.groupIds});

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  Future getGroups() async {
    print("getting groups");
    List<Group> groups = await DatabaseService().getUserGroups(widget.groupIds);

    groups.sort((a, b) => a.updateTime.compareTo(b.updateTime));

    print('user groups length : ${groups.length}');

    return groups.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGroups(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemBuilder: (_, index) {
              return GroupListItem(group: snapshot.data.elementAt(index));
            },
            itemCount: snapshot.data.length,
          );
        }
      },
    );

    // return ListView.builder(
    //   itemCount: groups.length ?? 0,
    //   itemBuilder: (BuildContext context, int index) {
    //     return GroupListItem(group: groups.elementAt(index));
    //   },
    // );
  }
}


