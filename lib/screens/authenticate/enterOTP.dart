import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:ttmm/services/auth.dart';
import 'package:validators/validators.dart';

class EnterOTP extends StatefulWidget {
  final String _phone;
  EnterOTP(this._phone);

  @override
  _EnterOTPState createState() => _EnterOTPState();
}

class _EnterOTPState extends State<EnterOTP> {
  final AuthService _authService = AuthService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _smsCode = '';
  bool _loading = false;
  bool _isCodeSent = false;

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
          PinEntryTextField(
            onSubmit: (val) => _smsCode = val,
            fields: 6,
          ),
          SizedBox(
            height: 30.0,
          ),
          RaisedButton(
              color: _isCodeSent ? Colors.white : Colors.green,
              child: Text(
                'Submit OTP',
                style: TextStyle(color: Colors.amber),
              ),
              onPressed: () async {
                if (isNumeric(_smsCode)) {
                  User user = await _authService
                      .logIn(_smsCode)
                      .whenComplete(() => setState(() => _loading = true));
                  if (user != null) {
                    Navigator.of(context).pop();
                  } else
                    print("Enter valid otp");
                }
              }),
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
