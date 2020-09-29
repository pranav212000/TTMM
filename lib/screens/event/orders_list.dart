import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/services/event_api_service.dart';
import 'package:ttmm/services/order_api_service.dart';

import 'order_item.dart';

class OrderList extends StatefulWidget {
  final String eventId;

  // ChildPage({Key key, this.function}) : super(key: key);

  // OrderList({Key key, @required this.eventId});
  const OrderList({Key key, @required this.eventId}) : super(key: key);
  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  List<Order> _orders = new List<Order>();
  Future _future;

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
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        else if (snapshot.data == null || snapshot.data.length == 0) {
          return Center(
            child: Text('No Orders yet!'),
          );
        } else {
          if (_orders.length != snapshot.data.length) _orders = snapshot.data;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: _orders.length,
            itemBuilder: (BuildContext context, int index) {
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                child: OrderItem(order: _orders[index]),
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
                                  'Are you sure you want to delete ${_orders[index].itemName}'),
                              actions: [
                                FlatButton(
                                    onPressed: () {
                                      deleteOrder(_orders[index].orderId);
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
                    onTap: () => Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('EDIT'),
                    )),
                  )
                ],
              );
            },
          );
        }
      },
    );
  }

  void refreshList(Order order) {
    setState(() {
      _orders.add(order);
    });
  }

  Future deleteOrder(String orderId) async {
    Response response = await OrderApiService.create().deleteOrder(orderId);
    Map<String, dynamic> map = response.body;

    if (map['isSuccess']) {
      Navigator.of(context).pop();
      setState(() {
        _orders.removeWhere((order) => order.orderId == orderId);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Order deleted')));
      });
    } else {
      Navigator.of(context).pop();
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete order')));
    }
  }
}
