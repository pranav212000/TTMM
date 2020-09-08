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
import 'package:ttmm/wrapper.dart';

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
          // setState(() {
          //   _userData = UserData(
          //       uid: snapshot.data()['uid'],
          //       name: snapshot.data()['name'],
          //       groups: snapshot.data()['groups'],
          //       phoneNumber: snapshot.data()['phoneNumber'],
          //       profileUrl: snapshot.data()['profileUrl']);
          //
          //   print(_userData.toString());
          // });

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
    List<Group> userGroups =
        await DatabaseService(phoneNumber: firebaseuser.phoneNumber)
            .getUserGroups(userData.groups);

    print('user groups length after await : ${userGroups.length}');
    if (this.mounted)
      setState(() {
        print('IN SET STATE');
        if (userGroups != null) {
          userGroups.sort((a, b) => a.updateTime.compareTo(b.updateTime));
          print('user groups length : ${userGroups.length}');
          _userGroups = userGroups.reversed.toList();
        } else
          _userGroups = new List<Group>();

        _loadingGroups = false;
        print('Loading complete in then');
      });
    // }).catchError((e) {
    //   setState(() {
    //     print('IN SET STATE');
    //
    //     _loadingGroups = false;
    //     print(e.toString());
    //     print('loading done in on error');
    //   });
    //
    //   _scaffoldKey.currentState
    //       .showSnackBar(SnackBar(content: Text('Could not load groups')));
    //   print('Could not load groups');
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _userGroups = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseuser = Provider.of<firebaseAuth.User>(context);

    // if (_userData == null) getUserData(firebaseuser);
    print(
        '-------------------------------------------------------------------------------------------------------');
    return StreamBuilder<UserData>(
        stream: DatabaseService(phoneNumber: firebaseuser.phoneNumber).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            print(userData.toJson());
            if (_userGroups == null) {
              print('get groups');
              getUserGroups(firebaseuser, userData);
            } else if ((_userGroups.length != userData.groups.length) &&
                !_loadingGroups) {
              print(_loadingGroups);
              print('getting groups');
              _loadingGroups = true;
              getUserGroups(firebaseuser, userData);
            } else {
              print('Groups length : ${_userGroups.length}');
              print('Loading in stream builder $_loadingGroups');
            }
            // print(userData.groups.length);
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
                                )
                              ],
                            ));
                  }
                },
                label: Text('Add Group'),
                icon: Icon(Icons.add),
              ),
              body: (_loadingGroups ||
                      (_userGroups != null ? _userGroups.length : 0) !=
                          userData.groups.length)
                  ? Loading()
                  : ((_userGroups.length == 0 && !_loadingGroups)
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
            );
          } else {
            return Loading();
          }
        });
  }
}
