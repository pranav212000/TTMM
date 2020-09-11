import 'package:flutter/material.dart';
import 'package:ttmm/models/user.dart';

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
    );
  }
}
