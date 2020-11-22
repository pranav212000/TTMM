import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:ttmm/models/event.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/screens/event/bill_payment.dart';
import 'package:ttmm/screens/event/order_item.dart';
import 'package:ttmm/screens/event/orders_list.dart';
import 'package:ttmm/screens/event/pay_person.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/hex_color.dart';
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
  SolidController _controller = SolidController();

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
    super.initState();
    if (widget.event == null) {
      _future = _getEvent("108c16c0-1616-11eb-850d-f1a437e4c224");
    }
    getPhoneNumber();
    // _orders = getOrders();
  }

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
          : "108c16c0-1616-11eb-850d-f1a437e4c224"),
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
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 5,
                    child: OrderList(
                        eventId: snapshot.data.eventId, key: _orderListKey),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
              bottomSheet: SolidBottomSheet(
                controller: _controller,
                maxHeight: 180,
                headerBar: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    height: 50,
                    child: Center(
                      child: Text("Swipe me!",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                body: ListView(
                  children: [
                    ListTile(
                      title: Text('Add Order'),
                      onTap: () {
                        _controller.hide();
                        addOrder(snapshot.data.eventId);
                      },
                    ),
                    ListTile(
                      title: Text('I\'m paying'),
                      onTap: () async {
                        _controller.hide();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) =>
                                    BillPayment(eventId: _event.eventId)))
                            .then((result) {
                          if (result == null)
                            showSnackbar(_scaffoldKey, 'Payment unsuccessful',
                                color: Colors.red);
                          if (result) {
                            showSnackbar(_scaffoldKey, 'Payment successful');
                          } else {
                            showSnackbar(_scaffoldKey, 'Payment unsuccessful',
                                color: Colors.red);
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: Text('Pay Person'),
                      onTap: () {
                        _controller.hide();
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    // FIXME just keep the eventId
                                    builder: (context) => PayPerson(
                                        eventId: widget.event != null
                                            ? widget.event.eventId
                                            : "108c16c0-1616-11eb-850d-f1a437e4c224")))
                            .then((result) {
                          if (result == null)
                            showSnackbar(_scaffoldKey, 'Payment unsuccessful',
                                color: Colors.red);
                          else {
                            if (result) {
                              showSnackbar(_scaffoldKey, 'Payment successful',
                                  color: Colors.green);
                            } else {
                              showSnackbar(_scaffoldKey, 'Payment unsuccessful',
                                  color: Colors.red);
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
                // body: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     RaisedButton(
                //       color: Colors.green,
                //       onPressed: () => addOrder(snapshot.data.eventId),
                //       child: Text('Add Order'),
                //     ),
                //     FlatButton(onPressed: null, child: Text('Click me!')),
                //     FlatButton(onPressed: null, child: Text('Click me!')),
                //   ],
                // ),
              ),
            );
          }
        }
      },
    );
  }

  Future addOrder(String eventId) async {
    String order;
    bool _isLoading = false;
    final _formkey = GlobalKey<FormState>();
    showDialog(
        barrierDismissible: false,
        context: _scaffoldKey.currentContext,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Stack(children: [
              AlertDialog(
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
                              decoration: InputDecoration(
                                  labelText: 'Order',
                                  hintText: 'Order',
                                  hintStyle: HINT_STYLE),
                              validator: (val) =>
                                  val.isEmpty ? 'Enter order name' : null,
                              onChanged: (val) => order = val,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  hintText: 'Quantity',
                                  hintStyle: HINT_STYLE),
                              keyboardType: TextInputType.number,
                              validator: (val) => val.isEmpty
                                  ? 'Enter quantity'
                                  : (!isNumeric(val) ? 'Enter a number' : null),
                              onChanged: (val) {
                                if (val.isEmpty) {
                                  setState(() {
                                    _quantity = 0;
                                  });
                                } else if (isNumeric(val))
                                  setState(() {
                                    _quantity = int.parse(val);
                                  });
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Cost',
                                  hintText: 'Cost',
                                  hintStyle: HINT_STYLE),
                              keyboardType: TextInputType.number,
                              validator: (val) => val.isEmpty
                                  ? 'Enter cost'
                                  : !isNumeric(val)
                                      ? 'Enter a number'
                                      : null,
                              onChanged: (val) {
                                if (val.isEmpty) {
                                  setState(() {
                                    _cost = 0;
                                  });
                                } else if (isNumeric(val))
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
                                child: Text(
                                  'Total Cost = ' + RS + '${_quantity * _cost}',
                                  style: GoogleFonts.josefinSans(),
                                )),
                            SizedBox(
                              height: 10.0,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              color: Colors.orange,
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_formkey.currentState.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });
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
            ]);
          });
        });
  }

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
      Map<String, dynamic> map = response.body;
      Order order = Order.fromJson(map['order']);

      _orderListKey.currentState.refreshList(order);

      showSnackbar(_scaffoldKey, 'SUCCESS');
      _quantity = 0;
      _cost = 0;
      Navigator.of(context).pop();
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
*/
