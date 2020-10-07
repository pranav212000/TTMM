import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/transaction.dart';
import 'package:ttmm/services/transaction_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:upi_india/upi_india.dart';
import 'package:validators/validators.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class BillPayment extends StatefulWidget {
  String eventId;

  BillPayment({@required this.eventId});
  @override
  _BillPaymentState createState() => _BillPaymentState();
}

class _BillPaymentState extends State<BillPayment> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUpi = false;
  int _amount = 0;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp> apps;
  String _upiId;
  String _name;
  String _phone;

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phone = preferences.getString(currentPhoneNUmber);
    print('GOT PHONE');
    print(_phone);
  }

  @override
  void initState() {
    _upiIndia.getAllUpiApps().then((value) {
      setState(() {
        apps = value;
      });
    });
    getPhoneNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Bill Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: _amount == 0 ? null : _amount.toString(),
                decoration: textInputDecoration.copyWith(labelText: 'Amount'),
                validator: (val) => val.isEmpty
                    ? 'Enter cost'
                    : !isNumeric(val) ? 'Enter a number' : null,
                onChanged: (val) {
                  if (isNumeric(val)) _amount = int.parse(val);
                },
              ),
              Row(
                children: [
                  Card(
                    color: Colors.green,
                    child: Container(
                      height: 100,
                      width: 130,
                      child: FlatButton(
                        child: Image.asset(
                          'assets/images/cash.png',
                          scale: 5,
                        ),
                        onPressed: () async {
                          print(_amount);
                          if (_formKey.currentState.validate()) {
                            if (_phone == null) await getPhoneNumber();
                            setState(() {
                              _isLoading = true;
                              postPayment(widget.eventId, _amount, cash);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.purple,
                    child: Container(
                      height: 100,
                      width: 130,
                      child: FlatButton(
                        child: Image.asset(
                          'assets/images/upi.png',
                          scale: 4,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (_phone == null)
                              await getPhoneNumber();
                            else {
                              String scanResult = await scanner.scan();
                              print(scanResult);
                              // String temp =
                              //     "upi://pay?pa=pranavpatil212000@oksbi&pn=Pranav%20Patil&aid=uGICAgIDJjPLAGw";
                              var decoded = Uri.decodeComponent(scanResult);

                              Uri uri = Uri.dataFromString(scanResult);
                              Map<String, dynamic> params = uri.queryParameters;
                              var uid = params['pa'];
                              var name = Uri.decodeComponent(params['pn']);
                              print(uid);
                              print(name);
                              print(decoded);
                              setState(() {
                                _upiId = uid;
                                _name = name;
                                _isUpi = true;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: _isLoading,
                  child: Center(
                    child: CircularProgressIndicator(),
                  )),
              Visibility(
                visible: _isUpi,
                child: apps != null
                    ? Flexible(
                        fit: FlexFit.loose,
                        child: Card(
                          child: GridView.count(
                            shrinkWrap: true,
                            // Create a grid with 2 columns. If you change the scrollDirection to
                            // horizontal, this produces 2 rows.
                            crossAxisCount: 3,
                            // Generate 100 widgets that display their index in the List.
                            children: List.generate(apps.length, (index) {
                              return ListTile(
                                title: Image.memory(apps[index].icon),
                                onTap: () async {
                                  UpiResponse _upiResponse =
                                      await initiateTransaction(
                                          apps[index].app);

                                  if (_upiResponse.error != null) {
                                    switch (_upiResponse.error) {
                                      case UpiError.APP_NOT_INSTALLED:
                                        print(
                                            "Requested app not installed on device");
                                        showSnackbar(_scaffoldKey,
                                            "Requested app not installed on device");
                                        break;
                                      case UpiError.INVALID_PARAMETERS:
                                        print(
                                            "Requested app cannot handle the transaction");
                                        showSnackbar(_scaffoldKey,
                                            "Requested app cannot handle the transaction");

                                        break;
                                      case UpiError.NULL_RESPONSE:
                                        print(
                                            "requested app didn't returned any response");
                                        showSnackbar(_scaffoldKey,
                                            "requested app didn't returned any response");

                                        break;
                                      case UpiError.USER_CANCELLED:
                                        print("You cancelled the transaction");
                                        showSnackbar(_scaffoldKey,
                                            "You cancelled the transaction");

                                        break;
                                    }
                                  } else {
                                    // TODO post payment after upi
                                    String status = _upiResponse.status;
                                    switch (status) {
                                      case UpiPaymentStatus.SUCCESS:
                                        print('Success');
                                        showSnackbar(
                                            _scaffoldKey, "Payment successful",
                                            color: Colors.green);

                                        postPayment(
                                            widget.eventId, _amount, upi);

                                        break;
                                      case UpiPaymentStatus.SUBMITTED:
                                        print('Submited');
                                        showSnackbar(
                                            _scaffoldKey, "Payment submitted",
                                            color: Colors.amber);
                                        break;
                                      case UpiPaymentStatus.FAILURE:
                                        print('FAILURE');
                                        showSnackbar(
                                            _scaffoldKey, "Payment failure",
                                            color: Colors.red);
                                        break;
                                      // default:
                                    }
                                  }
                                },
                              );
                            }),
                          ),
                        ),
                      )
                    : Text('No UPI apps'),
              )
            ],
          ),
        ),
        // child: ListView.builder(
        //   itemCount: apps.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return ListTile(
        //       title: Text(apps[index].app),
        //       leading: Image.memory(apps[index].icon),
        //       // Text(apps[index].app), Image.memory(apps[index].icon));
        //     );
        //   },
        // ),
        // ),
      ),
    );
  }

  void postPayment(String eventId, int amt, String mode) async {
    print('phoneNumber');
    print(_phone);
    Map<String, dynamic> body = {
      phoneNumber: _phone,
      paymentMode: mode,
      amount: amt
    };

    try {
      Response response =
          await TransactionApiService.create().postPaid(eventId, body);
      if (response.statusCode == 200) {
        print(response.body);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Response response = e;
      Map<String, dynamic> map = json.decode(response.body);
      print(map["error"]);
      Navigator.of(context).pop(false);
    }
  }

  Future<UpiResponse> initiateTransaction(String app) async {
    return _upiIndia.startTransaction(
      app: app, //  I took only the first app from List<UpiIndiaApp> app.
      receiverUpiId: _upiId, // Make Sure to change this UPI Id
      receiverName: _name,
      transactionRefId: 'testId',
      // TODO add a valid transaction note
      transactionNote: 'Not actual. Just an example.',
      amount: _amount.toDouble(),
    );
  }
}
