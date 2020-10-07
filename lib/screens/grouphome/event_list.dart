import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/screens/event/event_home.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/services/group_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:intl/intl.dart';

class EventList extends StatefulWidget {
  final String groupId;
  EventList({Key key, @required this.groupId}) : super(key: key);

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventList> {
  List<Event> _events = new List<Event>();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  Future _future = null;

  Future getEvents() async {
    Response response =
        await GroupApiService.create().getEvents(widget.groupId);

    if (response.statusCode == 200) {
      if (response.body != null) {
        for (dynamic item in response.body) {
          Event event = Event.fromJson(item);
          if (_events.indexOf(event) == -1) _events.add(event);
        }

        _events.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

        return _events;
      } else
        return null;
    } else {
      print('ERROR');
    }
  }

  @override
  void initState() {
    _future = getEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data == null || snapshot.data.length == 0) {
            return Center(child: Text('No events yet!'));
          } else {
            // TODO add is delete in following if while deleting event

            if (_events.length <= snapshot.data.length) {
              _events = snapshot.data;
            }
            _events.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            return ListView.builder(
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                Event event = _events.elementAt(index);
                String lastActivity = formatDate(event.updatedAt);
                return Card(
                  child: ListTile(
                    title: Text(event.eventName),
                    subtitle: Text("Last activity : $lastActivity"),
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
      },
    );
  }

  void refreshList(Event event) async {
    setState(() {
      _events.add(event);
    });
  }
}
