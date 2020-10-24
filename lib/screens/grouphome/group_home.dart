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
import 'package:vector_math/vector_math.dart' as math;
import 'package:ttmm/shared/loading.dart';
import 'package:uuid/uuid.dart';

class GroupHome extends StatefulWidget {
  final Group group;
  // FIXME change like event and order list
  GroupHome({@required this.group});

  @override
  _GroupHomeState createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EventListState> _eventListKey =
      new GlobalKey<EventListState>();

  // String _eventName = '';
  String splitType = evenly;
// TODO cache all possible things in floor!
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
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.group.groupIconUrl == null
                  ? Image.asset('assets/images/group_image.png').image
                  : Image.network(widget.group.groupIconUrl).image,
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
          showGeneralDialog(
              context: context,
              pageBuilder: (context, anim1, anim2) {},
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.4),
              barrierLabel: '',
              transitionBuilder: (context, anim1, anim2, child) {
                return Transform.rotate(
                  angle: math.radians(anim1.value * 360),
                  child: Opacity(
                    opacity: anim1.value,
                    child: AddEventDialog(
                      groupId: widget.group.groupId,
                      scaffoldKey: _scaffoldKey,
                      eventListKey: _eventListKey,
                    ),
                  ),
                );
              },
              transitionDuration: Duration(milliseconds: 300));

          // showDialog(
          //     context: _scaffoldKey.currentContext,
          //     builder: (BuildContext context) {
          //       return AddEventDialog(
          //         groupId: widget.group.groupId,
          //         scaffoldKey: _scaffoldKey,
          //         eventListKey: _eventListKey,
          //       );
          //     });
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
}

class AddEventDialog extends StatefulWidget {
  final String groupId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<EventListState> eventListKey;

  AddEventDialog(
      {@required this.groupId,
      @required this.scaffoldKey,
      @required this.eventListKey});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String _eventName = '';
  String splitType = evenly;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: Text('Create Event'),
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
                        decoration: InputDecoration(
                            labelText: 'Event Name',
                            hintText: 'Event Name',
                            hintStyle: TextStyle(color: Colors.grey[700])),
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
                              selectedItemBuilder: (BuildContext context) {
                                return <String>[evenly, byOrder]
                                    .map<Widget>((String value) {
                                  return Text(
                                    '${value[0].toUpperCase()}${value.substring(1)}',
                                  );
                                }).toList();
                              },
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
                        height: 25.0,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  // DatabaseService().addEvent(widget.group.groupId);
                                  String eventId = Uuid().v1();
                                  Event event = new Event(
                                      eventId: eventId,
                                      eventName: _eventName,
                                      transactionId: null);
                                  setState(() {
                                    postEvent(event, splitType);
                                  });
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
        ),
        Visibility(
            visible: _isLoading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: Colors.black38),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ))
      ],
    );
  }

  // TODO card with spinning animation spins while appearing and spins while disappearing
  void postEvent(Event event, String splitType) async {
    Response response = await EventApiService.create()
        .addEvent(widget.groupId, splitType, event.toJson());

    if (response.statusCode != 200) {
      showSnackbar(widget.scaffoldKey, 'Could not add event');
    } else {
      Event event = Event.fromJson(response.body);
      widget.eventListKey.currentState.refreshList(event);
      showSnackbar(widget.scaffoldKey, 'Event Added');
    }
    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }
}
