import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/screens/event/event_home.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:uuid/uuid.dart';

class GroupHome extends StatefulWidget {
  final Group group;

  GroupHome({@required this.group});

  @override
  _GroupHomeState createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _eventName = '';
// TODO
  Future getEvents() async {
    Response response = await EventApiService.create()
        .getEvents({'eventIds': widget.group.groupEvents});
    List<Event> events = new List<Event>();
    if (response.statusCode == 200) {
      for (dynamic event in response.body) {
        events.add(Event.fromJson(event));
      }
      return events;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(ModalRoute.of(context).settings.name);
    getEvents();
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
                      Form(
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
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              color: Colors.blue,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  // DatabaseService().addEvent(widget.group.groupId);
                                  String eventId = Uuid().v1();
                                  Event event = new Event(
                                      eventId: eventId, eventName: _eventName);

                                  addEvent(event);
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
      body: FutureBuilder(
        future: getEvents(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data == null) {
              return Center(child: Text('No events yet!'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Event event = snapshot.data.elementAt(index);
                  return Card(
                    child: ListTile(
                      title: Text(event.eventName),
                      subtitle: Text("Last activity : ${event.updatedAt}"),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EventHome(
                                event: event,
                              ))),
                    ),
                  );
                },
              );
            }
          }
          // return ;
        },
      ),
    );
  }

// TODO card with spinning animation spins while appearing and spins while disappearing
  void addEvent(Event event) async {
    Response response = await EventApiService.create()
        .addEvent(widget.group.groupId, event.toJson());

    print(response);
    if (response.statusCode != 200) {
      showSnackbar(_scaffoldKey, 'Could not add event');
    } else {
      showSnackbar(_scaffoldKey, 'Event Added');
    }
    setState(() {
      Navigator.of(context).pop();
    });
  }
}
