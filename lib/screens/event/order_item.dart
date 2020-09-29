import 'package:flutter/material.dart';
import 'package:ttmm/models/order.dart';

class OrderItem extends StatelessWidget {
  final Order order;

  OrderItem({@required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '${order.quantity}x',
                    style: TextStyle(fontSize: order.quantity < 99 ? 30 : 24),
                  ),
                  Text(
                    '\$${order.cost}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )),
        Expanded(
            flex: 9,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                order.itemName,
              ),
            )),
        Expanded(
            flex: 2,
            child: Text(
              '\$${order.totalCost}',
              maxLines: 1,
              // textAlign: TextAlign.end,
            )),
      ]),
    );
  }
}
