import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/home/group_list_item.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/group_api_service.dart';

class GroupList extends StatefulWidget {
  final List<dynamic> groupIds;

  GroupList({@required this.groupIds});

  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  Future getGroups() async {
    print("getting groups");

    Response response =
        await GroupApiService.create().getGroups({'groupIds': widget.groupIds});
    // print(response.body);

    List<dynamic> res = response.body;
    List<Group> groups = new List<Group>();

    for (dynamic item in res) {
      groups.add(Group.fromJson(item));
    }

    // print(groups.toString());
    return groups;
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
          if (snapshot.data != null)
            return ListView.builder(
              itemBuilder: (_, index) {
                return GroupListItem(group: snapshot.data.elementAt(index));
              },
              itemCount: snapshot.data.length,
            );
          else
            return CircularProgressIndicator();
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
