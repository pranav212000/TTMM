import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/transaction.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/services/firebase_api_service.dart';
import 'package:ttmm/services/group_api_service.dart';
import 'package:ttmm/services/transaction_api_service.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:ttmm/shared/shared_functions.dart';
import 'package:upi_india/upi_india.dart';
import 'package:uuid/uuid.dart';
import 'package:validators/validators.dart';

class PayPerson extends StatefulWidget {
  String eventId;

  PayPerson({@required this.eventId});
  @override
  _PayPersonState createState() => _PayPersonState();
}

class _PayPersonState extends State<PayPerson>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TabController _tabController;
  Future _futureToGet;
  Future _futureAll;
  String _upiId;
  String _name;
  String _phone;
  bool _isUpi = false;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> apps;
  String _amount = '';

  String _note;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    getPhoneNumber();

    _futureToGet = getAllToGets();
    _futureAll = getAllMembers();

    _upiIndia.getAllUpiApps().then((value) {
      setState(() {
        apps = value;
      });
    });
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
                    child: Text('No one to get any money yet'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> map = snapshot.data[index];
                      return ListTile(
                        title: Text(map['user'].name),
                        leading: CircleAvatar(
                          backgroundImage:
                              Image.network(map['user'].profileUrl).image,
                        ),
                        trailing: Text(map['amount'].toString()),
                        onTap: () async {
                          if (map['user'].upiId == null) {
                            showPaymentModeDialog(map['user']);
                          } else {
                            print('UPI ID IS ${map['user'].upiId}');
                            _upiId = map['user'].upiId;
                            _name = map['user'].name;
                            showPaymentModeDialog(map['user']);
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
                    child: Text('No-one'),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserData user = snapshot.data[index];
                        return ListTile(
                          title: Text(user.name),
                          leading: CircleAvatar(
                            backgroundImage:
                                Image.network(user.profileUrl).image,
                          ),
                          onTap: () async {
                            if (user.upiId == null) {
                              showPaymentModeDialog(user);
                            } else {
                              print('UPI ID IS ${user.upiId}');
                              _upiId = user.upiId;
                              _name = user.name;
                              showPaymentModeDialog(user);
                            }
                          },
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
      if (item[phoneNumber] != _phone) {
        phoneNumbers.add(item[phoneNumber]);
        amounts[item[phoneNumber]] = item[amount];
      }
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
        if (UserData.fromJson(item).phoneNumber != _phone)
          users.add(UserData.fromJson(item));
      }

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phone = preferences.getString(currentPhoneNUmber);
    print('GOT PHONE');
    print(_phone);
  }

  showPaymentModeDialog(UserData user) {
    showDialog(
        barrierDismissible: false,
        context: _scaffoldKey.currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter amount'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Amount', labelText: 'Amount'),
                      onChanged: (val) => _amount = val,
                      keyboardType: TextInputType.number,
                      validator: (val) => val.isEmpty
                          ? 'Enter amount'
                          : (!isNumeric(val) ? 'Enter a number' : null),
                    ),
                    TextField(
                      decoration:
                          InputDecoration(hintText: 'Note', labelText: 'Note'),
                      onChanged: (val) => _note = val,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 70,
                          width: 100,
                          child: FlatButton(
                            color: Colors.green,
                            child: Icon(Icons.payments_outlined),
                            // child: Image.asset(
                            //   'assets/images/cash.png',
                            //   scale: 5,
                            // ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                Map<String, dynamic> body = {
                                  "phoneNumber": _phone,
                                  "to": user.phoneNumber,
                                  "amount": _amount,
                                  "paymentId": Uuid().v1(),
                                  "eventId": widget.eventId
                                };
                                Response response =
                                    await FirebaseApiService.create()
                                        .sendCashConfirmation(body)
                                        .then((value) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });

                                print(response.body);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 70,
                          width: 100,
                          child: FlatButton(
                            child: Image.asset(
                              'assets/images/upi.png',
                              fit: BoxFit.fill,
                              // scale: 4,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if (_upiId == null) {
                                  print('NO UPI ID, SCAN QR CODE');

                                  String scanResult = await scanner.scan();
                                  print(scanResult);
                                  var decoded = Uri.decodeComponent(scanResult);

                                  Uri uri = Uri.dataFromString(scanResult);
                                  Map<String, dynamic> params =
                                      uri.queryParameters;
                                  var uid = params['pa'];
                                  var name = Uri.decodeComponent(params['pn']);
                                  print(uid);
                                  print(name);
                                  print(decoded);
                                  _upiId = uid;
                                  _name = name;
                                }
                                _isUpi = true;
                                Navigator.pop(context);
                                showAppsBottomSheet(user.phoneNumber);
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  showAppsBottomSheet(String to) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
            itemCount: apps.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.memory(
                    apps[index].icon,
                  ),
                ),
                title: Text(getUpiAppName(apps[index].app)),
                onTap: () async {
                  UpiResponse _upiResponse = await initiateTransaction(
                      apps[index].app,
                      _upiId,
                      _name,
                      double.parse(_amount),
                      _note);

                  if (_upiResponse.error != null) {
                    displayUpiError(_scaffoldKey, _upiResponse.error);
                  } else {
                    String status = _upiResponse.status;
                    switch (status) {
                      case UpiPaymentStatus.SUCCESS:
                        print('Success');
                        showSnackbar(_scaffoldKey, "Payment successful",
                            color: Colors.green);

                        postPayPerson(
                            widget.eventId, int.parse(_amount), upi, to);

                        break;
                      case UpiPaymentStatus.SUBMITTED:
                        print('Submited');
                        showSnackbar(_scaffoldKey, "Payment submitted",
                            color: Colors.amber);
                        break;
                      case UpiPaymentStatus.FAILURE:
                        print('FAILURE');
                        showSnackbar(_scaffoldKey, "Payment failure",
                            color: Colors.red);
                        break;
                      // default:
                    }
                  }
                },
              );
            },
          );
        });
  }

  postPayPerson(String eventId, int amt, String mode, String toPhone) async {
    Map<String, dynamic> body = {
      phoneNumber: _phone,
      paymentMode: mode,
      amount: amt,
      to: toPhone
    };
    try {
      Response response =
          await TransactionApiService.create().postPayPerson(eventId, body);
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);

      print(response.body);
    } catch (e) {
      Response response = e;
      Map<String, dynamic> map = json.decode(response.body);
      print(map["error"]);
      Navigator.of(context).pop(false);
      Navigator.of(context).pop(false);
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
