import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/order.dart';
import 'package:ttmm/screens/event/order_item.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = getUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.length == 0
                ? Center(child: Text('No orders yet'))
                : ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OrderItem(
                        order: Order.fromJson(snapshot.data[index]['order']),
                      );
                    },
                  );
          }
        },
      ),
    );
  }

  Future getUserOrders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String phoneNumber = preferences.getString(currentPhoneNUmber);
    Response response =
        await UserApiService.create().getUserOrders(phoneNumber);
    print(response.body);
    print(Order.fromJson(response.body[0]['order']));

    return response.body;
  }
}
