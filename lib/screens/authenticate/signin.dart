import 'package:flutter/material.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/screens/authenticate/enterOTP.dart';

// class SignIn extends StatefulWidget {
//   @override
//   _SignInState createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> {

//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

class SignIn extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String _phone = '';
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration:
                      textInputDecoration.copyWith(hintText: "Phone Number"),
                  validator: (val) {
                    if (val.isEmpty) {
                      return 'Please enter phone number';
                    } else if (val.length != 10) {
                      return 'Please enter valid number';
                    } else
                      return null;
                  },
                  onChanged: (val) {
                    _phone = '+91' + val;
                  },
                ),
                FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnterOTP(_phone)));
                    }
                  },
                  child: Text("Verify"),
                )
              ],
            ),
          )),
    );
  }
}
