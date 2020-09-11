import 'package:flutter/material.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/home/group_list_item.dart';

class GroupList extends StatelessWidget {
  final List<Group> groups;

  GroupList({@required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return GroupListItem(group: groups.elementAt(index));
      },
    );
  }
}
