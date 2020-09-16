import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/models/user.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/screens/grouphome/group_home.dart';

class GroupListItem extends StatefulWidget {
  final Group group;

  GroupListItem({@required this.group});

  @override
  _GroupListItemState createState() => _GroupListItemState();
}

class _GroupListItemState extends State<GroupListItem> {
  List<UserData> _users;
  bool _loading = true;
  String _currentPhone;

  void getCurrentPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _currentPhone = preferences.getString(currentPhoneNUmber);
  }

  Widget getSubtitle() {
    String subtitle;
    List<String> names = new List<String>();

    _users.forEach((user) {
      names.add(user.name);
    });

    if (names.length > 3) {
      subtitle = names.sublist(0, 2).join(',');
    } else {
      subtitle = names.join(',');
    }

    return Text(subtitle);
  }

  Future getUsers() async {
    List<UserData> users =
        await DatabaseService().getUsers(widget.group.groupMembers);
    if (users != null) if (this.mounted)
      setState(() {
        _users = users;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_users == null) getUsers();
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 10,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        title: Text(widget.group.groupName ?? "No name to group"),
        subtitle: _loading ? Text('') : getSubtitle(),
        leading: CircleAvatar(
          backgroundImage: widget.group.groupIconUrl == null
              ? Image.asset('assets/images/group_image.png').image
              : Image.network(widget.group.groupIconUrl).image,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GroupHome(group: widget.group)));
        },
      ),
    );
  }
}
