import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/screens/event/event_home.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/services/group_api_service.dart';

class EventList extends StatefulWidget {
  final String groupId;
  EventList({Key key, @required this.groupId}) : super(key: key);

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventList> {
  List<Event> _events = new List<Event>();
  Future _future;

  Future getEvents() async {
    Response response =
        await GroupApiService.create().getEvents(widget.groupId);

    if (response.statusCode == 200) {
      if (response.body != null) {
        for (dynamic item in response.body) {
          Event event = Event.fromJson(item);
          if (_events.indexOf(event) == -1) _events.add(event);
        }
        return _events;
      } else
        return null;
    } else {
      print('ERROR');
    }

    // List<Event> events = new List<Event>();
    // if (response.statusCode == 200) {
    //   for (dynamic event in response.body) {
    //     events.add(Event.fromJson(event));
    //   }
    //   return events;
    // }
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
          if (snapshot.data == null) {
          } else if (snapshot.data.length == 0) {
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
      },
    );
  }

  void refreshList(Event event) {
    setState(() {
      _events.add(event);
    });
  }
}
