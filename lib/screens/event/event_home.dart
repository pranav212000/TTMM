import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

class EventHome extends StatefulWidget {
  final Event event;

  EventHome({this.event});

  @override
  _EventHomeState createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  int _quantity = 0;
  int _cost = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _phoneNumber;
  Future _future;
  Future _orders;

  // TODO clear this shit jugad
  Event _event = new Event(
      eventId: "8c6a84f0-0173-11eb-b751-cf68f76509dc",
      eventName: "EVENT LOADING");
  Future<Event> _getEvent(String eventId) async {
    Response response = await EventApiService.create()
        .getEvent("8c6a84f0-0173-11eb-b751-cf68f76509dc");
    if (response.statusCode == 200) {
      if (response.body != null) return Event.fromJson(response.body);
    }

    return null;
  }

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phoneNumber = preferences.getString(currentPhoneNUmber);
  }

  Future getOrders() async {
    Response response =
        await EventApiService.create().getOrders(_event.eventId);

    List<Order> orders = new List<Order>();
    if (response.statusCode == 200) {
      if (response.body != null) {
        for (dynamic item in response.body) {
          Order order = Order.fromJson(item);
          orders.add(order);
        }
        return orders;
      } else
        return null;
    } else
      print('ERROR');
  }

  @override
  void initState() {
    if (widget.event == null) {
      _future = _getEvent("8c6a84f0-0173-11eb-b751-cf68f76509dc");
    }
    getPhoneNumber();
    _orders = getOrders();
    super.initState();
  }

// TODO refresh the list of orders!!!
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // TODO  future: _getEvent(widget.event.eventId),
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Loading();
        else {
          if (snapshot.data == null) {
            return Center(child: Text('Could not get the group'));
          } else {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(snapshot.data.eventName),
              ),
              body: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.75,
                      child: snapshot.data.orders == null ||
                              snapshot.data.orders.length == 0
                          ? Center(
                              child: Text('No orders yet'),
                            )
                          : Card(
                              child: FutureBuilder(
                                future: _orders,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return CircularProgressIndicator();
                                  else if (snapshot.data == null ||
                                      snapshot.data.length == 0) {
                                    return Center(
                                      child: Text('No Orders yet!'),
                                    );
                                  } else
                                    return ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          title: Text(
                                              snapshot.data[index].itemName),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                // mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Quantity : ',
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  Text('Cost : ',
                                                      textAlign:
                                                          TextAlign.right),
                                                  Text('Total : ',
                                                      textAlign:
                                                          TextAlign.right),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                // mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(snapshot
                                                      .data[index].quantity
                                                      .toString()),
                                                  Text(snapshot.data[index].cost
                                                      .toString()),
                                                  Text(snapshot
                                                      .data[index].totalCost
                                                      .toString()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                },
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.deepPurple,
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                onPressed: () =>
                                    addOrder(snapshot.data.eventId),
                                color: Colors.deepOrange,
                                child: Text('Add Order'),
                              ),
                              RaisedButton(
                                onPressed: null,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                onPressed: () {},
                                color: Colors.deepOrange,
                                child: Text('Pay'),
                              ),
                              RaisedButton(onPressed: null),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

// TODO make a separate page with better UI this dialog is ****
  Future addOrder(String eventId) async {
    String order;
    final _formkey = GlobalKey<FormState>();
    showDialog(
        context: _scaffoldKey.currentContext,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Enter order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Order'),
                            validator: (val) =>
                                val.isEmpty ? 'Enter order name' : null,
                            onChanged: (val) => order = val,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Quantity'),
                            validator: (val) => val.isEmpty
                                ? 'Enter quantity'
                                : (!isNumeric(val) ? 'Enter a number' : null),
                            onChanged: (val) {
                              if (isNumeric(val))
                                setState(() {
                                  _quantity = int.parse(val);
                                });
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            decoration:
                                textInputDecoration.copyWith(labelText: 'Cost'),
                            validator: (val) => val.isEmpty
                                ? 'Enter cost'
                                : !isNumeric(val) ? 'Enter a number' : null,
                            onChanged: (val) {
                              if (isNumeric(val))
                                setState(() {
                                  _cost = int.parse(val);
                                });
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Visibility(
                              visible:
                                  _quantity == 0 || _cost == 0 ? false : true,
                              child: Text('Total Cost = ${_quantity * _cost}')),
                          SizedBox(
                            height: 10.0,
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Colors.blue,
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                // TODO add order model!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                postOrder(order, eventId);
                              }
                              // if (_formKey.currentState.validate()) {
                              //   // DatabaseService().addEvent(widget.group.groupId);
                              //   String eventId = Uuid().v1();
                              //   Event event = new Event(
                              //       eventId: eventId, eventName: _eventName);

                              //   addEvent(event);
                              // }
                            },
                            child: Text('Create'),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

// TODO add other quantities as parameters too!
  Future postOrder(String order, String eventId) async {
    Response response = await EventApiService.create().addOrder(eventId, {
      'orderId': Uuid().v1(),
      'eventId': _event.eventId,
      'phoneNumber': _phoneNumber,
      'itemName': order,
      'quantity': _quantity,
      'cost': _cost,
      'totalCost': _quantity * _cost
    });

    if (response.statusCode == 200) {
      print('SUCCESS');
      showSnackbar(_scaffoldKey, 'SUCCESS');
    } else {
      showSnackbar(_scaffoldKey, 'ERROR');
    }
    print(response.body);
    Navigator.of(context).pop();
  }
}

// TODO
/* 
  All orders ,
  My orders,
  Bill,
  who paid,
  Who paid how much,
  How much do I owe to whom



*/
