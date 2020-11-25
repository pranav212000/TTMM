import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Order> _orders = new List();
  @override
  void initState() {
    super.initState();
    _future = getUserOrders();
  }

  void _onRefresh() async {
    // monitor network fetch
    _future = await getUserOrders()
        .whenComplete(() => _refreshController.refreshCompleted());
    // if failed,use refreshFailed()
  }

  void _onLoading() async {
    // monitor network fetch
    _future = getUserOrders().whenComplete(() {
      if (mounted) setState(() {});
      _refreshController.loadComplete();
    });
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // _orders.add((_orders.length + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('My Orders')),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data == null || snapshot.data.length == 0
                ? Center(child: Text('No orders yet'))
                : SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: WaterDropHeader(),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Text("pull up load");
                        } else if (mode == LoadStatus.loading) {
                          body = CupertinoActivityIndicator();
                        } else if (mode == LoadStatus.failed) {
                          body = Text("Load Failed!Click retry!");
                        } else if (mode == LoadStatus.canLoading) {
                          body = Text("release to load more");
                        } else {
                          body = Text("No more Data");
                        }
                        return Container(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return OrderItem(
                          order: snapshot.data[index],
                        );
                      },
                    ),
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
    List<Order> orders = new List<Order>();
    for (Map<String, dynamic> obj in response.body) {
      orders.add(Order.fromJson(obj['order']));
    }

    print(orders);
    
    return orders;
  }
}
