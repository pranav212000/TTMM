import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/screens/event/orders_list.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/services/group_api_service.dart';
import 'package:ttmm/services/order_api_service.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

class AddEditOrder extends StatefulWidget {
  final GlobalKey<OrderListState> orderListKey;
  final Order order;
  final String eventId;
  AddEditOrder({this.order, this.eventId, this.orderListKey});

  @override
  _AddEditOrderState createState() => _AddEditOrderState();
}

class _AddEditOrderState extends State<AddEditOrder> {
  UserData currentUser;
  List<UserData> eventMembers = new List();
  GlobalKey<FormState> _formKey = new GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  int _cost = 0, _quantity = 0;
  String _order;
  List<Map<String, dynamic>> _members = new List<Map<String, dynamic>>();
  TextEditingController _quantityController;
  bool _isLoading = true;

  @override
  void initState() {
    getCurrentUser();

    if (widget.order != null) {
      getEventMembers(widget.order.eventId);
      _order = widget.order.itemName;
      _quantity = widget.order.quantity;
      _cost = widget.order.cost;
      _members = widget.order.members;
    } else if (widget.eventId != null) {
      getEventMembers(widget.eventId);
    }
    _quantityController = new TextEditingController(text: _quantity.toString());
    super.initState();
  }

  void getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String currentPhone = preferences.getString(currentPhoneNUmber);
    Response response = await UserApiService.create().getUser(currentPhone);
    if (response.statusCode == 200) {
      setState(() {
        currentUser = UserData.fromJson(response.body);
        if (widget.order == null) {
          _members.add({"phoneNumber": currentUser.phoneNumber, 'quantity': 0});
        }
      });
    }
  }

  void getEventMembers(String eventId) async {
    Response phoneNumbersResponse =
        await GroupApiService.create().getMembersByEventId(eventId);

    if (phoneNumbersResponse.statusCode == 200) {
      Map<String, dynamic> body = new Map();
      body["phoneNumbers"] = phoneNumbersResponse.body;
      Response response = await UserApiService.create().getUsers(body);
      if (response.statusCode == 200) {
        for (dynamic user in response.body) {
          eventMembers.add(UserData.fromJson(user));
        }
        print('Event Members : ');
        print(eventMembers);

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(widget.order != null ? 'Edit Order' : 'Add Order')),
      body: Stack(children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  initialValue: _order == null ? '' : _order,
                  decoration: inputDecoration,
                  validator: (val) => val.isEmpty ? 'Enter order name' : null,
                  onChanged: (val) {
                    setState(() {
                      _order = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: inputDecoration.copyWith(
                          labelText: 'Quantity',
                          hintText: 'Quantity',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                      enabled: false,
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
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextFormField(
                      initialValue:
                          widget.order == null ? '' : _cost.toString(),
                      decoration: inputDecoration.copyWith(
                          labelText: 'Cost',
                          hintText: 'Cost',
                          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                      keyboardType: TextInputType.number,
                      validator: (val) => val.isEmpty
                          ? 'Enter cost'
                          : (!isNumeric(val) ? 'Enter a number' : null),
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
                  ),
                ],
              ),
              SizedBox(height: 30),
              Visibility(
                visible: _quantity == 0 || _cost == 0 ? false : true,
                child: Text(
                  'Total Cost = ' + RS + ' ${(_quantity * _cost)}',
                  style: GoogleFonts.josefinSans(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Members',
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: eventMembers.length == 0
                          ? Text(_members.elementAt(index)['phoneNumber'])
                          : Text(eventMembers
                              .elementAt(eventMembers.indexWhere((element) =>
                                  element.phoneNumber ==
                                  _members.elementAt(index)['phoneNumber']))
                              .name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: _members.elementAt(index)['quantity'] >
                                      0
                                  ? () {
                                      setState(() {
                                        _members.elementAt(index)['quantity']--;
                                        _quantity--;
                                        _quantityController.text =
                                            _quantity.toString();
                                      });
                                    }
                                  : null),
                          Text(
                            _members.elementAt(index)['quantity'].toString(),
                            style: GoogleFonts.josefinSans(fontSize: 18),
                          ),
                          IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _members.elementAt(index)['quantity']++;
                                  _quantity++;
                                  _quantityController.text =
                                      _quantity.toString();
                                });
                              }),
                        ],
                      ),
                    );
                  },
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
      ]),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 1,
            onPressed: () {
              if (_isLoading) {
                showSnackbar(_scaffoldKey, 'Please wait loading members');
              } else {
                if (_members.length == eventMembers.length) {
                  showSnackbar(_scaffoldKey, 'All members already added!');
                } else {
                  List<UserData> temp = new List();
                  temp.addAll(eventMembers);
                  _members.forEach((member) {
                    int index = eventMembers.indexWhere((eMember) =>
                        member['phoneNumber'] == eMember.phoneNumber);
                    if (index != -1) {
                      temp.removeAt(index);
                    }
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Choose Member'),
                          content: Container(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: temp.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(temp.elementAt(index).name),
                                  onTap: () {
                                    setState(() {
                                      _members.add({
                                        'phoneNumber':
                                            temp.elementAt(index).phoneNumber,
                                        'quantity': 0
                                      });
                                      Navigator.of(context).pop();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      });
                }
              }
            },
            tooltip: 'Add member',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            heroTag: 2,
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState.validate()) {
                      if (_quantity == 0) {
                        showSnackbar(_scaffoldKey, 'Please add quantity!');
                      } else {
                        setState(() {
                          _isLoading = true;
                          if (widget.order == null) {
                            //  Add order
                            addOrder();
                          } else {
                            //Update order
                            updateOrder();
                          }
                        });
                      }
                    }
                  },
            child: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }

  void addOrder() async {
    Response response =
        await EventApiService.create().addOrder(widget.eventId, {
      'orderId': Uuid().v1(),
      'eventId': widget.eventId,
      'members': _members,
      'itemName': _order,
      'quantity': _quantity,
      'cost': _cost,
      'creator': currentUser.phoneNumber,
      'totalCost': _quantity * _cost
    });

    if (response.statusCode == 200) {
      print('SUCCESS');
      Map<String, dynamic> map = response.body;
      Order order = Order.fromJson(map['order']);

      if (widget.orderListKey != null)
        widget.orderListKey.currentState.refreshList(order);

      showSnackbar(_scaffoldKey, 'SUCCESS');
      _quantity = 0;
      _cost = 0;
      Navigator.of(context).pop();
    } else {
      showSnackbar(_scaffoldKey, 'ERROR');
    }
    print(response.body);
  }
  // TODO

  void updateOrder() async {
    Order order = widget.order;

    order.members = _members;
    order.quantity = _quantity;
    order.totalCost = _quantity * _cost;
    order.cost = _cost;
    if (order.updatedAt == null || order.createdAt == null) {
      order.createdAt = DateTime.now();
      order.updatedAt = DateTime.now();
    }

    Response response = await OrderApiService.create()
        .updateOrder(widget.order.orderId, order.toJson());
    if (response.statusCode == 200) {
      // TODO
      if (response.body != null) {
        order = Order.fromJson(response.body);
      }
      // ?refresh list
      // widget.orderListKey.currentState.updateOrderList(order);
      Navigator.of(context).pop();
    }
  }
}
