import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/grouphome/group_home.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/shared/loading.dart';

class Wrapper extends StatelessWidget {
  Future<List<Group>> getGroups() async {
    List<dynamic> groupIds = new List<dynamic>();

    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');
    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');

    return await DatabaseService().getUserGroups(groupIds);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // if (user == null)
    //   return SignIn();
    // else
    //   return Home();

// TODO delete following builder and uncomment above 

    return FutureBuilder(
      future: getGroups(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Loading();
        else {
          return GroupHome(
            group: snapshot.data.elementAt(0),
          );
        }
      },
    );
  }
}
