import 'package:flutter/material.dart';
import 'package:ttmm/models/group.dart';

class GroupHome extends StatefulWidget {
  final Group group;

  GroupHome({@required this.group});

  @override
  _GroupHomeState createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.group.groupIconUrl == null
                    ? Image.asset('assets/images/group_image.png').image
                    : Image.network(widget.group.groupIconUrl).image,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: FlatButton(
              child: Align(
                child: Text(
                  widget.group.groupName,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                alignment: Alignment.centerLeft,
              ),
              onPressed: null,
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        label: Text('Event'),
        icon: Icon(Icons.add),
      ),
      body: Center(child: Text('GROUP HOME')),
    );
  }
}
