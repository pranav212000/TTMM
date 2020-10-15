import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/models/transaction.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/services/group_api_service.dart';
import 'package:ttmm/services/transaction_api_service.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';

class PayPerson extends StatefulWidget {
  String eventId;

  PayPerson({@required this.eventId});
  @override
  _PayPersonState createState() => _PayPersonState();
}

class _PayPersonState extends State<PayPerson>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  Future _futureToGet;
  Future _futureAll;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _futureToGet = getAllToGets();
    _futureAll = getAllMembers();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Select Contact'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'To Get',
            ),
            Tab(
              text: 'All',
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
            future: _futureToGet,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text('Noone to get any money yet'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> map = snapshot.data[index];
                      return ListTile(
                        title: Text(map['user'].name),
                        trailing: Text(map['amount'].toString()),
                        onTap: () {
                          if (map['user'].upiId == null) {
                            print('NO UPI ID SCAN QR CODE');
                          } else {
                            print('UPI ID IS ${map['user'].upiId}');
                          }
                        },
                      );
                    },
                  );
                }
              }
            },
          ),
          FutureBuilder(
            future: _futureAll,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                if (snapshot.data == null) {
                  return Center(
                    child: Text('Could not get members, Please try again'),
                  );
                } else if (snapshot.data.length == 0) {
                  return Center(
                    child: Text('No-one to yet'),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserData user = snapshot.data[index];
                        return ListTile(
                          title: Text(user.name),
                        );
                      });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future getAllToGets() async {
    Response response =
        await TransactionApiService.create().allToGets(widget.eventId);

    List<String> phoneNumbers = new List<String>();
    Map<String, dynamic> amounts = new Map<String, dynamic>();
    for (Map<String, dynamic> item in response.body) {
      phoneNumbers.add(item[phoneNumber]);
      amounts[item[phoneNumber]] = item[amount];
    }

    Map<String, dynamic> body = {'phoneNumbers': phoneNumbers};

    Response usersResponse = await UserApiService.create().getUsers(body);

    List<Map<String, dynamic>> users = new List<Map<String, dynamic>>();
    for (Map<String, dynamic> item in usersResponse.body) {
      users.add({
        'user': UserData.fromJson(item),
        'amount': amounts[item['phoneNumber']]
      });
    }

    return users;
  }

  Future getAllMembers() async {
    try {
      Response response =
          await GroupApiService.create().getMembersByEventId(widget.eventId);

      List<dynamic> phoneNumbers = response.body;
      Map<String, dynamic> body = {'phoneNumbers': phoneNumbers};

      Response usersResponse = await UserApiService.create().getUsers(body);
      List<UserData> users = new List<UserData>();
      for (Map<String, dynamic> item in usersResponse.body) {
        users.add(UserData.fromJson(item));
      }

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Widget _fabs() {
  //   return _tabController.index == 0
  //       ? FloatingActionButton(
  //           shape: StadiumBorder(),
  //           onPressed: () async {
  //             if (_selectedNumbers.length > 0) {
  //               String result = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => new AddGroup(_selectedNumbers)));

  //               if (result == 'OK') {
  //                 Navigator.of(context).pop('OK');
  //               }
  //             } else
  //               _scaffoldKey.currentState.showSnackBar(SnackBar(
  //                 content: Text(
  //                   'Please select a contact',
  //                   style: TextStyle(color: Colors.black),
  //                 ),
  //                 backgroundColor: Colors.red,
  //               ));
  //           },
  //           child: Icon(
  //             Icons.navigate_next,
  //             size: 20.0,
  //           ))
  //       : FloatingActionButton(
  //           shape: StadiumBorder(),
  //           onPressed: null,
  //           backgroundColor: Colors.redAccent,
  //           child: Icon(
  //             Icons.edit,
  //             size: 20.0,
  //           ),
  //         );
  // }
}
