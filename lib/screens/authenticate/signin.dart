import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 200, top: 70),
                          child: Text("TTMM")),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                              primaryColor: Colors.orange,
                              accentColor: Colors.orange),
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone_android,
                              ),
                              enabled: true,
                              hintText: "Phone Number",
                              labelText: 'Phone Number',
                              hintStyle: TextStyle(color: Colors.grey[700]),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                            ),
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
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.bottomLeft,
                      //   child: Container(
                      //       margin: EdgeInsets.all(30),
                      //       decoration: BoxDecoration(
                      //           shape: BoxShape.circle, color: Colors.white),
                      //       child: IconButton(
                      //           icon: Icon(
                      //             Icons.arrow_right,
                      //             color: Colors.black,
                      //           ),
                      //           onPressed: null)
                      Container(
                        margin: EdgeInsets.only(top: 50),
                        child: RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();

                              preferences.setString(currentPhoneNUmber, _phone);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EnterOTP(_phone)));
                            }
                          },
                          child: Text("Verify"),
                        ),
                      ),
                    ]))));

    //  Container(
    //   height: double.infinity,
    //   width: double.infinity,
    //   decoration: BoxDecoration(
    //       image:
    //           DecorationImage(image: AssetImage('assets/images/back.png'))),
    //   child: Form(
    //       key: _formKey,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Container(
    //             margin: EdgeInsets.only(left: 50, right: 50),
    //             padding: EdgeInsets.only(top: 10),
    //             child: Theme(
    //               data: Theme.of(context).copyWith(
    //                 primaryColor: Colors.white,
    //               ),
    //               child: TextFormField(
    //                 keyboardType: TextInputType.number,
    //                 decoration: textInputDecoration.copyWith(
    //                   hintText: "Phone Number",
    //                   labelText: 'Phone Number',
    //                 ),
    //                 validator: (val) {
    //                   if (val.isEmpty) {
    //                     return 'Please enter phone number';
    //                   } else if (val.length != 10) {
    //                     return 'Please enter valid number';
    //                   } else
    //                     return null;
    //                 },
    //                 onChanged: (val) {
    //                   _phone = '+91' + val;
    //                 },
    //               ),
    //               // child: TextFormField(
    //               //   decoration: InputDecoration(
    //               //     prefixIcon: Icon(
    //               //       Icons.payment,
    //               //     ),
    //               //     enabled: true,
    //               //     hintText: 'UPI ID',
    //               //     enabledBorder: UnderlineInputBorder(
    //               //       borderSide: BorderSide(color: Colors.white),
    //               //     ),
    //               //     focusedBorder: UnderlineInputBorder(
    //               //       borderSide: BorderSide(color: Colors.white),
    //               //     ),
    //               //   ),
    //               //   onChanged: (val) => _upi = val,
    //               // ),
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () {
    //               if (_formKey.currentState.validate()) {
    //                 Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (context) => EnterOTP(_phone)));
    //               }
    //             },
    //             child: Text("Verify"),
    //           )
    //         ],
    //       )),
    // ),
    // );
  }
}
