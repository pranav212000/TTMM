import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ttmm/services/auth.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:validators/validators.dart';

class EnterOTP extends StatefulWidget {
  final String _phone;
  EnterOTP(this._phone);

  @override
  _EnterOTPState createState() => _EnterOTPState();
}

class _EnterOTPState extends State<EnterOTP> {
  var onTapRecognizer;

  final AuthService _authService = AuthService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _smsCode = '';
  bool _loading = false;
  bool _isCodeSent = false;
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
  void verifyPhone() async {
    if (!_isCodeSent) {
      await _authService
          .verifyPhone(_scaffoldKey, widget._phone, enableButton)
          .whenComplete(() => _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Verification Done!'),
              )));
    }
  }

  void enableButton() {
    setState(() {
      print('isCode sent true');
      _isCodeSent = true;
    });
  }

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => verifyPhone());

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Enter OTP')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'We have sent an OTP to ${widget._phone}.\n Please enter the OTP to continue',
            style: TextStyle(),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30.0,
          ),
          Form(
            key: _formKey,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  // pastedTextStyle: TextStyle(
                  //   color: Colors.green.shade600,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  length: 6,
                  obscureText: false,
                  obscuringCharacter: '*',
                  animationType: AnimationType.fade,
                  // validator: (v) {
                  //   if (v.length != 3) {
                  //     return "PLease enter valid OTP";
                  //   } else {
                  //     return null;
                  //   }
                  // },
                  // pinTheme: PinTheme(
                  //   shape: PinCodeFieldShape.box,
                  //   borderRadius: BorderRadius.circular(5),
                  //   fieldHeight: 60,
                  //   fieldWidth: 50,
                  //   activeFillColor: hasError ? Colors.orange : Colors.white,
                  // ),
                  cursorColor: Colors.white,
                  animationDuration: Duration(milliseconds: 300),
                  textStyle: TextStyle(fontSize: 20, height: 1.6),
                  backgroundColor: Colors.transparent,

                  // enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  // boxShadows: [
                  //   BoxShadow(
                  //     offset: Offset(0, 1),
                  //     color: Colors.black12,
                  //     blurRadius: 10,
                  //   )
                  // ],
                  onCompleted: (val) {
                    _smsCode = val;
                  },
                  // onTap: () {
                  //   print("Pressed");
                  // },
                  // onChanged: (value) {
                  //   print(value);
                  //   setState(() {
                  //     currentText = value;
                  //   });
                  // },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                  onChanged: (String value) {},
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: RaisedButton(
                color: _isCodeSent ? Colors.orange : Colors.grey,
                child: Text(
                  'Submit OTP',
                  // style: TextStyle(color: Colors.amber),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (isNumeric(_smsCode)) {
                      User user = await _authService
                          .logIn(_smsCode)
                          .whenComplete(() => setState(() => _loading = true));
                      if (user != null) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _loading = false;
                        });

                        showSnackbar(_scaffoldKey, "Enter Valid OTP");
                      }
                    }
                  }
                }),
          ),
          SizedBox(height: 30.0),
          Visibility(
            child: SpinKitCubeGrid(
              color: Colors.orange,
              size: 30.0,
            ),
            visible: _loading,
          ),
        ],
      ),
    );
  }
}
