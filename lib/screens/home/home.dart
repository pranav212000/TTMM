import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/models/user.dart';
import 'package:ttmm/screens/contacts/contacts_page.dart';
import 'package:ttmm/screens/home/register.dart';
import 'package:ttmm/services/auth.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  UserData _userData;
  List<Group> _userGroups;
  bool _loadingGroups = true;

  Future getUserData(firebaseAuth.User user) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      users.doc(user.phoneNumber).get().then((DocumentSnapshot snapshot) {
        if (!snapshot.exists) {
          print('Document doesn\'t exist');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Register(
                user: user,
              ),
            ),
          );
        } else {
          preferences.setString(currentUser, user.uid);
          preferences.setString(currentPhoneNUmber, user.phoneNumber);
          setState(() {
            _userData = UserData(
                uid: snapshot.data()['uid'],
                name: snapshot.data()['name'],
                groups: snapshot.data()['groups'],
                phoneNumber: snapshot.data()['phoneNumber'],
                profileUrl: snapshot.data()['profileUrl']);

            print(_userData.toString());
          });

          print('Document exists');
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

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

  Future getUserGroups(
      firebaseAuth.User firebaseuser, UserData userData) async {
    await DatabaseService(phoneNumber: firebaseuser.phoneNumber)
        .getUserGroups(userData.groups)
        .then((userGroups) {
      setState(() {
        _userGroups = userGroups;
      });
    }).whenComplete(() {
      setState(() {
        _loadingGroups = false;
      });
    }).catchError((e) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Could not load groups')));
      print('Could not load groups');
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseuser = Provider.of<firebaseAuth.User>(context);

    if (_userData == null) getUserData(firebaseuser);

    return StreamBuilder<UserData>(
        stream: DatabaseService(phoneNumber: firebaseuser.phoneNumber).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;

            if (_userGroups == null) getUserGroups(firebaseuser, userData);
            print(userData.groups.length);
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
              drawer: Drawer(
                child: ListView(
                  children: [
                    UserAccountsDrawerHeader(
                      accountName:
                          Text(userData == null ? 'New User' : userData.name),
                      accountEmail: Text(
                          userData == null ? 'New User' : userData.phoneNumber),
                      arrowColor: Colors.red,
                      currentAccountPicture: Container(
                        child: userData == null
                            ? CircleAvatar(
                                radius: 70,
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 60,
                                ))
                            : CircleAvatar(
                                radius: 70,
                                backgroundImage:
                                    Image.network(userData.profileUrl).image),
                      ),
                    ),
                    ListTile(
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      title: Text(
                        'Home',
                      ),
                      leading: Icon(
                        Icons.home,
                        color: Colors.blue,
                      ),
                    ),

                    // Divider(

                    //   thickness: 2,
                    // ),
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Colors.blue,
                      ),
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      title: Text('Signout'),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  final PermissionStatus permissionStatus =
                      await _getPermission();
                  if (permissionStatus == PermissionStatus.granted) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ContactsPage()));
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
                                )
                              ],
                            ));
                  }
                },
                label: Text('Add Group'),
                icon: Icon(Icons.add),
              ),
              body: _loadingGroups
                  ? Loading()
                  : ((_userGroups.length == 0)
                      ? Center(child: Text('No groups yet'))
                      : ListView.builder(
                          itemCount: _userGroups.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                  _userGroups.elementAt(index).groupName ??
                                      "No name to group"),
                            );
                          },
                        )),

              // body: userData.groups.length == 0
              //     ? ListView.builder(
              //         itemCount: userData?.groups?.length ?? 0,
              //         itemBuilder: (BuildContext context, int index) {
              //           return ListTile(
              //             title: Text(userData.groups.elementAt(index)),
              //           );
              //         },
              //       )
              //     : Center(
              //         child: Text('No Groups Yet'),
              //       ),
            );
          } else {
            return Loading();
          }
        });
  }
}
