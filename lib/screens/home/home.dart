import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/screens/contacts/contacts_page.dart';
import 'package:ttmm/screens/home/group_list.dart';
import 'package:ttmm/screens/authenticate/register.dart';
import 'package:ttmm/services/auth.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/drawer.dart';
import 'package:ttmm/wrapper.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  List<Group> _userGroups;
  bool _loadingGroups = true;

  Future<UserData> _future;

  @override
  bool get wantKeepAlive => true;
  // Future getUserData(firebaseAuth.User user) async {
  //   try {
  //     UserApiService.create().checkUserExists(user.uid).then((response) {
  //       print("RESPONSE BODY : ");
  //       print(response.body);
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }

  //   try {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();

  //     users.doc(user.phoneNumber).get().then((DocumentSnapshot snapshot) {
  //       if (!snapshot.exists) {
  //         print('Document doesn\'t exist');
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => Register(
  //               user: user,
  //             ),
  //           ),
  //         );
  //       } else {
  //         preferences.setString(currentUser, user.uid);
  //         preferences.setString(currentPhoneNUmber, user.phoneNumber);

  //         print('Document exists');
  //       }
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  @override
  void initState() {
    super.initState();

    _future = _getUserData();
  }

  Future<UserData> _getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String phoneNumber = preferences.getString(currentPhoneNUmber);

    Response response = await UserApiService.create().getUser(phoneNumber);

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
    final firebaseuser = Provider.of<firebaseAuth.User>(context);
    super.build(context);

    return FutureBuilder<UserData>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<UserData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.data != null)
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Home'),
                actions: <Widget>[
                  FlatButton.icon(
                      onPressed: () {
                        showSnackbar(_scaffoldKey, 'Signing out');
                        AuthService().signout();
                      },
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Signout',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
              drawer: MyDrawer(userData: snapshot.data),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  final PermissionStatus permissionStatus =
                      await _getPermission();
                  if (permissionStatus == PermissionStatus.granted) {
                    String result = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ContactsPage()));

                    if (result == 'OK') {
                      print('RESULT OK');
                      _userGroups = null;
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Wrapper()));
                    } else {
                      print("Group not created");
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: Text('Permissions error'),
                              content: Text('Please enable contacts access '
                                  'permission in system settings'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ));
                  }
                },
                label: Text('Add Group'),
                icon: Icon(Icons.add),
              ),
              // body: (_loadingGroups ||
              //         (_userGroups != null ? _userGroups.length : 0) !=
              //             userData.groups.length)
              //     ? Loading()
              // : ((_userGroups.length == 0 && !_loadingGroups)
              body: snapshot.data.groups.length == 0
                  ? Center(child: Text('No groups yet'))
                  : GroupList(
                      groupIds: snapshot.data.groups,
                    ),

// TODO add bottom navigation bar
              // bottomNavigationBar: CurvedNavigationBar(items: null),
            );
          else
            return registerUser(firebaseuser);
        }
      },
    );
  }

  Widget registerUser(firebaseAuth.User firebaseUser) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Register(
                user: firebaseUser,
              )));
    });

    return Scaffold(body: Center(child: Text('User not registered yet')));
  }
}
