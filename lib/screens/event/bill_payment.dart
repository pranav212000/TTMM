import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/transaction.dart';
import 'package:ttmm/services/transaction_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/shared/shared_functions.dart';
import 'package:upi_india/upi_india.dart';
import 'package:validators/validators.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class BillPayment extends StatefulWidget {
  final String eventId;

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
  Future _futureTransaction;

  TextEditingController controller = new TextEditingController(text: '');

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phone = preferences.getString(currentPhoneNUmber);
    print('GOT PHONE');
    print(_phone);
  }

  @override
  void initState() {
    _futureTransaction = getTransaction();
    _upiIndia.getAllUpiApps().then((value) {
      setState(() {
        apps = value;
      });
    });
    getPhoneNumber();
    super.initState();
  }

  Future getTransaction() async {
    Response response =
        await TransactionApiService.create().getTranasaction(widget.eventId);

    print('body : ');
    print(response.body);

// FIXME transaction from json isn't working
    print('transaction : ');
    Transaction transaction = Transaction.fromJson(response.body);

    print(transaction);
    if (response.statusCode == 200) return response.body;
  }

// TODO add the total bill amount paid amount and remaining amount just to fill the page looks pretty empty right now
// FIXME also add the bottom sheet which is probably not there right now
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTransaction(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          print('DATA');
          print(snapshot.data);
          if (snapshot.data == null) {
            return Center(
              child: Text(
                  'Could not get transaction details, please try again later'),
            );
          } else {
            Transaction transaction = Transaction.fromJson(snapshot.data);
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Bill Payment'),
              ),
              resizeToAvoidBottomInset: false,
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                            initialValue:
                                _amount == 0 ? null : _amount.toString(),
                            decoration: inputDecoration.copyWith(
                                labelText: 'Amount', hintText: 'Amount'),
                            keyboardType: TextInputType.number,
                            validator: (val) => val.isEmpty
                                ? 'Enter amount'
                                : !isNumeric(val)
                                    ? 'Enter a number'
                                    : null,
                            onChanged: (val) {
                              if (isNumeric(val)) _amount = int.parse(val);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: TextFormField(
                                initialValue: transaction.totalCost.toString(),
                                decoration: inputDecoration.copyWith(
                                    labelText: 'Total Bill',
                                    hintText: 'Total Bill'),
                                enabled: false,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: TextFormField(
                                initialValue: transaction.totalPaid.toString(),
                                decoration: inputDecoration.copyWith(
                                    labelText: 'Total Paid',
                                    hintText: 'Total Paid'),
                                enabled: false,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Due : ' +
                              RS +
                              '${transaction.totalCost - transaction.totalPaid}',
                          style: GoogleFonts.josefinSans(fontSize: 38),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Choose Payment Method',
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              color: Colors.green,
                              child: Container(
                                height: _isUpi ? 50 : 100,
                                width: _isUpi ? 60 : 130,
                                child: FlatButton(
                                  child: Image.asset(
                                    'assets/images/cash.png',
                                    scale: 5,
                                  ),
                                  onPressed: () async {
                                    print(_amount);
                                    if (_isUpi)
                                      setState(() {
                                        _isUpi = false;
                                      });
                                    else if (_formKey.currentState.validate()) {
                                      if (_phone == null)
                                        await getPhoneNumber();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.purple,
                              child: Container(
                                height: _isUpi ? 100 : 50,
                                width: _isUpi ? 130 : 60,
                                child: FlatButton(
                                  child: Image.asset(
                                    'assets/images/upi.png',
                                    scale: 4,
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      if (_phone == null) {
                                        showSnackbar(_scaffoldKey,
                                            'Please wait fetching information!');
                                        await getPhoneNumber();
                                      } else {
                                        setState(() {
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
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                              visible: _isUpi,
                              child: TextFormField(
                                controller: controller,
                                decoration: inputDecoration.copyWith(
                                    labelText: 'UPI ID', hintText: 'UPI ID'),
                                onChanged: (val) => _upiId = val,
                                validator: (val) =>
                                    val.isEmpty ? 'Enter UPI ID' : null,
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Visibility(
                            visible: _isUpi,
                            child: RaisedButton(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Scan QR code',
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              ),
                              onPressed: () async {
                                String scanResult = await scanner.scan();
                                print(scanResult);
                                // String temp =
                                //     "upi://pay?pa=pranavpatil212000@oksbi&pn=Pranav%20Patil&aid=uGICAgIDJjPLAGw";
                                var decoded = Uri.decodeComponent(scanResult);

                                Uri uri = Uri.dataFromString(scanResult);
                                Map<String, dynamic> params =
                                    uri.queryParameters;
                                var uid = params['pa'];
                                var name = Uri.decodeComponent(params['pn']);
                                print(uid);
                                print(name);
                                print(decoded);
                                setState(() {
                                  _upiId = uid;
                                  controller.text = uid;
                                  _name = name;
                                  _isUpi = true;
                                });
                              },
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          child: Text('PAY'),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if (_isUpi) {
                                showAppsBottomSheet();
                              } else {
                                setState(() {
                                  _isLoading = true;
                                  postPayment(widget.eventId, _amount, cash);
                                });
                              }
                            }
                          },
                        ),
                        Visibility(
                            visible: _isLoading,
                            child: Center(
                              child: CircularProgressIndicator(),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  void showAppsBottomSheet() {
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
                      _amount.toDouble(),
                      'asdfasdfasdf');

                  if (_upiResponse.error != null) {
                    displayUpiError(_scaffoldKey, _upiResponse.error);
                  } else {
                    String status = _upiResponse.status;
                    switch (status) {
                      case UpiPaymentStatus.SUCCESS:
                        print('Success');
                        showSnackbar(_scaffoldKey, "Payment successful",
                            color: Colors.green);

                        postPayment(widget.eventId, _amount, upi);

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

                      default:
                        print('PENDING');
                        showSnackbar(_scaffoldKey, "Payment not complete yet!",
                            color: Colors.blue);
                    }
                  }
                },
              );
            },
          );
        });
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
          await TransactionApiService.create().postPayBill(eventId, body);
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

  // Future<UpiResponse> initiateTransaction(String app) async {
  //   return _upiIndia.startTransaction(
  //     app: app, //  I took only the first app from List<UpiIndiaApp> app.
  //     receiverUpiId: _upiId, // Make Sure to change this UPI Id
  //     receiverName: _name,
  //     transactionRefId: 'testId',
  //     // TODO add a valid transaction note
  //     transactionNote: 'Not actual. Just an example.',
  //     amount: _amount.toDouble(),
  //   );
  // }

}
