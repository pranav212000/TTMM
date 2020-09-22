import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/shared/constants.dart';

class GroupHome extends StatefulWidget {
  final Group group;

  GroupHome({@required this.group});

  @override
  _GroupHomeState createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    print('NAME IN GROUP HOME');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context).settings.name);

    return Scaffold(
      key: _scaffoldKey,
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
              onPressed: () => setState(() {}),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: _scaffoldKey.currentContext,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Enter event name'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Event'),
                              validator: (val) =>
                                  val.isEmpty ? 'Enter event name' : null,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                                  color: Colors.blue,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  // DatabaseService().addEvent(widget.group.groupId);

                                }
                              },
                              child: Text('Create'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        label: Text('Event'),
        icon: Icon(Icons.add),
      ),
      body: Center(child: Text('GROUP HOME')),
    );
  }
}
