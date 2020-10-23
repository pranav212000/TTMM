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
        body: Container(
            height: double.infinity,
            width: double.infinity,
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //       fit: BoxFit.cover,
            //       image: AssetImage('assets/images/back.png')),
            // ),
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 200),
                          child: Text("TTMM")),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Colors.white,
                          ),
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone_android,
                              ),
                              enabled: true,
                              hintText: "Phone Number",
                              labelText: 'Phone Number',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
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
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EnterOTP(_phone)));
                          }
                        },
                        child: Text("Verify"),
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
