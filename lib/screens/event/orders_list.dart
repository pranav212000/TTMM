import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/services/order_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:validators/validators.dart';

import 'order_item.dart';

class OrderList extends StatefulWidget {
  final String eventId;


  const OrderList({Key key, @required this.eventId}) : super(key: key);
  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  List<Order> _orders = new List<Order>();
  Future _future;
  final SlidableController slidableController = SlidableController();

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future getOrders() async {
    Response response =
        await EventApiService.create().getOrders(widget.eventId);

    if (response.statusCode == 200) {
      if (response.body != null) {
        for (dynamic item in response.body) {
          print(item);
          Order order = Order.fromJson(item);
          if (_orders.indexOf(order) == -1) _orders.add(order);
        }
        return _orders;
      } else
        return null;
    } else
      print('ERROR');
  }

  @override
  void initState() {
    _future = getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        else if (snapshot.data == null || snapshot.data.length == 0) {
          print('INSIDE NULL IF');
          return Center(
            child: Text('No Orders yet!'),
          );
        } else {
          return AnimatedList(
            key: listKey,
            shrinkWrap: true,
            initialItemCount: _orders.length,
            itemBuilder:
                (BuildContext context, int index, Animation animation) {
              return _buildItem(_orders[index], animation);
            },
          );
        }
      },
    );
  }

  void refreshList(Order order) {
    if (_orders == null || _orders.length == 0) {
      print(_future.toString());
      _future = getOrders();
    } else
      setState(() {
        _orders.add(order);
        listKey.currentState.insertItem(_orders.length - 1);
      });
  }

  Widget _buildItem(Order order, Animation animation) {
    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset(0, 0),
      )),
      child: Slidable(
        key: Key(order.itemName),
        controller: slidableController,
        actionPane: SlidableDrawerActionPane(),
        child: OrderItem(order: order),
        actions: [
          IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirm'),
                      content: Text(
                          'Are you sure you want to delete ${order.itemName}'),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              deleteOrder(order.orderId);
                              setState(() {});
                            },
                            child: Text('Yes')),
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).pop();
                              });
                            },
                            child: Text('No'))
                      ],
                    );
                  },
                );
              }),
        ],
        secondaryActions: [
          IconSlideAction(
            caption: 'Edit',
            color: Colors.amber,
            icon: Icons.edit,
            onTap: () =>
                updateOrder(order, order.itemName, order.quantity, order.cost),
          ),
        ],
      ),
    );
  }

  void updateOrder(Order order, String item, int quantity, int cost) {
    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Enter order'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: item,
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Order'),
                              validator: (val) =>
                                  val.isEmpty ? 'Enter order name' : null,
                              onChanged: (val) => item = val,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              initialValue: quantity.toString(),
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Quantity'),
                              validator: (val) => val.isEmpty
                                  ? 'Enter quantity'
                                  : (!isNumeric(val) ? 'Enter a number' : null),
                              onChanged: (val) {
                                if (isNumeric(val))
                                  setState(() {
                                    quantity = int.parse(val);
                                  });
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              initialValue: cost.toString(),
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Cost'),
                              validator: (val) => val.isEmpty
                                  ? 'Enter cost'
                                  : !isNumeric(val) ? 'Enter a number' : null,
                              onChanged: (val) {
                                if (isNumeric(val))
                                  setState(() {
                                    cost = int.parse(val);
                                  });
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                                visible:
                                    quantity == 0 || cost == 0 ? false : true,
                                child: Text('Total Cost = ${quantity * cost}')),
                            SizedBox(
                              height: 10.0,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              color: Colors.blue,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  postUpdate(order, item, quantity, cost);
                                }
                              },
                              child: Text('Update'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Future postUpdate(Order order, String item, int quantity, int cost) async {
    String orderId = order.orderId;
    order.itemName = item;
    order.quantity = quantity;
    order.cost = cost;
    order.totalCost = cost * quantity;
    if (order.updatedAt == null || order.createdAt == null) {
      order.createdAt = DateTime.now();
      order.updatedAt = DateTime.now();
    }

    Response response =
        await OrderApiService.create().updateOrder(orderId, order.toJson());
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      if (response.body != null) {
        order = Order.fromJson(response.body);
        setState(() {
          _orders[_orders.indexWhere(
              (listorder) => listorder.orderId == order.orderId)] = order;
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Order updated')));
        });
      }
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update Order')));
    }
  }

  Future deleteOrder(String orderId) async {
    Response response = await OrderApiService.create().deleteOrder(orderId);
    Map<String, dynamic> map = response.body;

    if (map['isSuccess']) {
      Navigator.of(context).pop();
      setState(() {
        int index = _orders.indexWhere((order) => order.orderId == orderId);
        var removedItem = _orders.removeAt(index);
        listKey.currentState.removeItem(index, (context, animation) {
          _buildItem(removedItem, animation);
        });

        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Order deleted')));
      });
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete order')));
    }
  }
}
