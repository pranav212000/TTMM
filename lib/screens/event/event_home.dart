import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/screens/event/bill_payment.dart';
import 'package:ttmm/screens/event/order_item.dart';
import 'package:ttmm/screens/event/orders_list.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:qrscan/qrscan.dart' as scanner;
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

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<OrderListState> _orderListKey =
      new GlobalKey<OrderListState>();

  String _phoneNumber;
  Future _future;
  Future _orders;

  // TODO clear this shit jugad
  Event _event;
  // Event _event = new Event(
  //     eventId: "8c6a84f0-0173-11eb-b751-cf68f76509dc",
  //     eventName: "EVENT LOADING", transactionId: null);
  Future<Event> _getEvent(String eventId) async {
    Response response = await EventApiService.create().getEvent(eventId);
    if (response.statusCode == 200) {
      if (response.body != null) {
        Event event = Event.fromJson(response.body);
        // if (event.eventId != _event.eventId ||
        //     event.orders.length != _event.orders.length)
        if (_event == null)
          setState(() {
            _event = event;
          });
        return event;
      }
    }
    return null;
  }

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phoneNumber = preferences.getString(currentPhoneNUmber);
  }

  @override
  void initState() {
    if (widget.event == null) {
      _future = _getEvent("040a68d0-07dd-11eb-b854-b701c410207c");
    }
    getPhoneNumber();
    // _orders = getOrders();
    super.initState();
  }

// TODO refresh the list of orders!!!
// FIXME this is a must -^
  @override
  Widget build(BuildContext context) {
    print('WIDGET EVENT');
    print(widget.event);

    return FutureBuilder(
      // TODO  future: _getEvent(widget.event.eventId),
      // TODO remove the hardcoded event ID finally
      // FIXME
      future: _getEvent(widget.event != null
          ? widget.event.eventId
          : "040a68d0-07dd-11eb-b854-b701c410207c"),
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
                            // TODO extract this future builder to another widget.....orders list like group list probably!
                            : OrderList(
                                eventId: snapshot.data.eventId,
                                key: _orderListKey)),
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
                                onPressed: () async {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) => BillPayment(
                                              eventId: _event.eventId)))
                                      .then((result) {
                                    if (result) {
                                      showSnackbar(
                                          _scaffoldKey, 'Payment successful');
                                    } else {
                                      showSnackbar(
                                          _scaffoldKey, 'Payment unsuccessful',
                                          color: Colors.red);
                                    }
                                  });

                                  // TODO get data the code from here
                                  // String scanResult = await scanner.scan();
                                  // print(scanResult);
                                  // String temp =
                                  //     "upi://pay?pa=pranavpatil212000@oksbi&pn=Pranav%20Patil&aid=uGICAgIDJjPLAGw";
                                  // var decoded = Uri.decodeFull(temp);
                                  // print(decoded);
                                },
                                color: Colors.deepOrange,
                                child: Text('I\'m paying'),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  String temp =
                                      "upi://pay?pa=pranavpatil212000@oksbi&pn=Pranav%20Patil&aid=uGICAgIDJjPLAGw";
                                  var decoded = Uri.decodeComponent(temp);

                                  Uri uri = Uri.dataFromString(temp);
                                  Map<String, dynamic> params =
                                      uri.queryParameters;
                                  var uid = params['pa'];
                                  var name = params['pn'];
                                  print(uid);
                                  print(Uri.decodeComponent(name));
                                  print(decoded);
                                },
                                child: Text('DECODE'),
                              ),
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
                                postOrder(order, eventId);
                              }
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
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      print('SUCCESS');
      Map<String, dynamic> map = response.body;
      Order order = Order.fromJson(map['order']);

      _orderListKey.currentState.refreshList(order);
      showSnackbar(_scaffoldKey, 'SUCCESS');
    } else {
      showSnackbar(_scaffoldKey, 'ERROR');
    }
    print(response.body);
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
