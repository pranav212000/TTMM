import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/shared/constants.dart';

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
              color: Colors.orange,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '${order.quantity}x',
                    style: GoogleFonts.josefinSans(fontSize: order.quantity < 99 ? 30 : 24),
                  ),
                  Text(
                    RS + '${order.cost}',
                    style: GoogleFonts.josefinSans(fontSize: 14),
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
              RS + '${order.totalCost}',
              maxLines: 1,
              style: GoogleFonts.josefinSans(),
              // textAlign: TextAlign.end,
            )),
      ]),
    );
  }
}
