import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/navigator.dart';
import 'package:ttmm/screens/authenticate/signin.dart';
import 'package:ttmm/screens/grouphome/addgroup.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';

import 'models/userdata.dart';

class Wrapper extends StatelessWidget {
  Future<List<Group>> getGroups() async {
    print("CURRENT TIME :");
    print(Timestamp.fromDate(DateTime.now()));

    List<dynamic> groupIds = new List<dynamic>();

    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');
    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');

    return await DatabaseService().getUserGroups(groupIds);
  }

  Future<UserData> _getUserData(firebaseAuth.User firebaseuser) async {
    Response response = await UserApiService.create().getUser(firebaseuser.uid);

    if (response.statusCode == 200) {
      UserData userData = UserData.fromJson(response.body);
      print('USER DATA FROM API : ');
      print(userData.toJson());
      return userData;
    } else {
      print('User not found!');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<firebaseAuth.User>(context);

    if (user == null)
      return SignIn();
    else {
      setSharedPreferences(user);
      return NavigatorPage();
    }
// TODO fix this jugad!
    // else {
    //   setSharedPreferences(user);
    //   return EventHome();
    // }
  }

  void setSharedPreferences(firebaseAuth.User user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(currentUser, user.uid);
    preferences.setString(currentPhoneNUmber, user.phoneNumber);
  }
}
