import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/event/event_home.dart';
import 'package:ttmm/screens/grouphome/event_list.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:uuid/uuid.dart';

class GroupHome extends StatefulWidget {
  final Group group;
  // FIXME change like event and order list
  final String groupId;
  GroupHome({@required this.group, this.groupId});

  @override
  _GroupHomeState createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<EventListState> _eventListKey =
      new GlobalKey<EventListState>();

  bool _loading = false;
  String _eventName = '';
  String splitType = evenly;

  @override
  Widget build(BuildContext context) {
    // print(ModalRoute.of(context).settings.name);
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
              // TODO on pressed show group info or something!
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
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                    labelText: 'Event'),
                                validator: (val) =>
                                    val.isEmpty ? 'Enter event name' : null,
                                onChanged: (val) => _eventName = val,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Split Type : '),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      items: <String>[evenly, byOrder]
                                          .map((String value) => DropdownMenuItem(
                                              child: Text(
                                                  '${value[0].toUpperCase()}${value.substring(1)}')))
                                          .toList(),
                                      onChanged: (val) => splitType = val,
                                      hint: Text('Please choose split type'),
                                    ),
                                  ),
                                ],
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
                                    String eventId = Uuid().v1();
                                    Event event = new Event(
                                        eventId: eventId,
                                        eventName: _eventName);

                                    postEvent(event, splitType);
                                  }
                                },
                                child: Text('Create'),
                              )
                            ],
                          ),
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
      body: EventList(
        key: _eventListKey,
        groupId: widget.group.groupId,
      ),
    );
  }

// TODO card with spinning animation spins while appearing and spins while disappearing
  void postEvent(Event event, String splitType) async {
    Response response = await EventApiService.create()
        .addEvent(widget.group.groupId, splitType, event.toJson());

    print(response);
    if (response.statusCode != 200) {
      showSnackbar(_scaffoldKey, 'Could not add event');
    } else {
      Event event = Event.fromJson(response.body);
      _eventListKey.currentState.refreshList(event);
      showSnackbar(_scaffoldKey, 'Event Added');
    }
    setState(() {
      Navigator.of(context).pop();
    });
  }
}
