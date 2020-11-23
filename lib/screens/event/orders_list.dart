import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/screens/event/add_edit_order.dart';
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
  bool _isLoading = false;
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
      if (_orders == null) _orders = new List<Order>();
      setState(() {
        _future = getOrders();
      });
    } else
      setState(() {
        _orders.add(order);
        listKey.currentState.insertItem(_orders.length - 1);
      });
  }

  void updateOrderList(Order order) {
    setState(() {
      _orders[_orders.indexWhere(
          (listorder) => listorder.orderId == order.orderId)] = order;
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Order updated')));
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
              color: Colors.redAccent,
              icon: Icons.delete,
              onTap: () {
                deleteOrder(order);
              }),
        ],
        secondaryActions: [
          IconSlideAction(
              caption: 'Edit',
              color: Colors.blueAccent,
              icon: Icons.edit,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddEditOrder(order: order)))
              // updateOrder(order, order.itemName, order.quantity, order.cost),
              ),
        ],
      ),
    );
  }

  // void updateOrder(Order order, String item, int quantity, int cost) {
  //   bool _isLoading = false;
  //   showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (_) {
  //         return StatefulBuilder(
  //           builder: (BuildContext context, setState) {
  //             return Stack(children: [
  //               AlertDialog(
  //                 title: Text('Enter order'),
  //                 content: SingleChildScrollView(
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Form(
  //                         key: _formKey,
  //                         child: Column(
  //                           children: [
  //                             TextFormField(
  //                               initialValue: item,
  //                               decoration: InputDecoration(
  //                                   labelText: 'Order',
  //                                   hintText: 'Order',
  //                                   hintStyle: HINT_STYLE),
  //                               validator: (val) =>
  //                                   val.isEmpty ? 'Enter order name' : null,
  //                               onChanged: (val) => item = val,
  //                             ),
  //                             SizedBox(
  //                               height: 10.0,
  //                             ),
  //                             TextFormField(
  //                               initialValue: quantity.toString(),
  //                               decoration: InputDecoration(
  //                                   labelText: 'Quantity',
  //                                   hintText: 'Quantity',
  //                                   hintStyle: HINT_STYLE),
  //                               keyboardType: TextInputType.number,
  //                               validator: (val) => val.isEmpty
  //                                   ? 'Enter quantity'
  //                                   : (!isNumeric(val)
  //                                       ? 'Enter a number'
  //                                       : null),
  //                               onChanged: (val) {
  //                                 if (val.isEmpty) {
  //                                   setState(() {
  //                                     quantity = 0;
  //                                   });
  //                                 } else if (isNumeric(val))
  //                                   setState(() {
  //                                     quantity = int.parse(val);
  //                                   });
  //                               },
  //                             ),
  //                             SizedBox(
  //                               height: 10.0,
  //                             ),
  //                             TextFormField(
  //                               initialValue: cost.toString(),
  //                               decoration: InputDecoration(
  //                                   labelText: 'Cost',
  //                                   hintText: 'Cost',
  //                                   hintStyle: HINT_STYLE),
  //                               keyboardType: TextInputType.number,
  //                               validator: (val) => val.isEmpty
  //                                   ? 'Enter cost'
  //                                   : !isNumeric(val)
  //                                       ? 'Enter a number'
  //                                       : null,
  //                               onChanged: (val) {
  //                                 if (val.isEmpty) {
  //                                   setState(() {
  //                                     cost = 0;
  //                                   });
  //                                 } else if (isNumeric(val))
  //                                   setState(() {
  //                                     cost = int.parse(val);
  //                                   });
  //                               },
  //                             ),
  //                             SizedBox(
  //                               height: 10.0,
  //                             ),
  //                             Visibility(
  //                                 visible:
  //                                     quantity == 0 || cost == 0 ? false : true,
  //                                 child: Text(
  //                                     'Total Cost = ' +
  //                                         RS +
  //                                         '${quantity * cost}',
  //                                     style: GoogleFonts.josefinSans())),
  //                             SizedBox(
  //                               height: 10.0,
  //                             ),
  //                             RaisedButton(
  //                               shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(10.0)),
  //                               color: Colors.orange,
  //                               onPressed: _isLoading
  //                                   ? null
  //                                   : () {
  //                                       if (_formKey.currentState.validate()) {
  //                                         setState(() {
  //                                           _isLoading = true;
  //                                         });
  //                                         postUpdate(
  //                                             order, item, quantity, cost);
  //                                       }
  //                                     },
  //                               child: Text('Update'),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Visibility(
  //                   visible: _isLoading,
  //                   child: Container(
  //                     width: double.infinity,
  //                     height: double.infinity,
  //                     decoration: BoxDecoration(color: Colors.black38),
  //                     child: Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //                   ))
  //             ]);
  //           },
  //         );
  //       });
  // }

  // Future postUpdate(Order order, String item, int quantity, int cost) async {
  //   String orderId = order.orderId;
  //   order.itemName = item;
  //   order.quantity = quantity;
  //   order.cost = cost;
  //   order.totalCost = cost * quantity;
  //   if (order.updatedAt == null || order.createdAt == null) {
  //     order.createdAt = DateTime.now();
  //     order.updatedAt = DateTime.now();
  //   }

  //   Response response =
  //       await OrderApiService.create().updateOrder(orderId, order.toJson());
  //   Navigator.of(context).pop();

  //   if (response.statusCode == 200) {
  //     if (response.body != null) {
  //       order = Order.fromJson(response.body);
  //       // setState(() {
  //       //   _orders[_orders.indexWhere(
  //       //       (listorder) => listorder.orderId == order.orderId)] = order;
  //       //   Scaffold.of(context)
  //       //       .showSnackBar(SnackBar(content: Text('Order updated')));
  //       // });
  //     }
  //   } else {
  //     Scaffold.of(context)
  //         .showSnackBar(SnackBar(content: Text('Could not update Order')));
  //   }
  // }

  void deleteOrder(Order order) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Stack(children: [
            AlertDialog(
              title: Text('Confirm'),
              content:
                  Text('Are you sure you want to delete ${order.itemName}'),
              actions: [
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      postDeleteOrder(order.orderId);
                      setState(() {});
                    },
                    child: Text('Yes')),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = false;
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text('No'))
              ],
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
      },
    );
  }

  Future postDeleteOrder(String orderId) async {
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

        _isLoading = false;
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Order deleted')));
      });
    } else {
      _isLoading = false;
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete order')));
    }
  }
}
