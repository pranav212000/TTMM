import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/services/auth.dart';

class MyDrawer extends StatelessWidget {
  UserData userData;
  MyDrawer({@required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userData == null ? 'New User' : userData.name),
            accountEmail:
                Text(userData == null ? 'New User' : userData.phoneNumber),
            arrowColor: Colors.red,
            currentAccountPicture: Container(
              child: userData == null
                  ? CircleAvatar(
                      radius: 70,
                      child: Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Theme.of(context).iconTheme.color,
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
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
            ),
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Text('Signout'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Are you sure you want to signout ?'),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              AuthService().signout();
                              Navigator.of(context).pop();
                            },
                            child: Text('Yes')),
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No')),
                      ],
                    );
                  }).whenComplete(() => Navigator.of(context).pop());
            },
          ),
        ],
      ),
    );
  }
}
