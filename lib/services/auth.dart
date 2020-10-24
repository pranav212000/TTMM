import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/screens/authenticate/signin.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:ttmm/wrapper.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  BuildContext context;

  AuthService({this.context});

  String _verificationId;

  Future verifyPhone(GlobalKey<ScaffoldState> _scaffoldKey, String phone,
      Function codeSentCallback) async {
    try {
      _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(e.message),
            ));
            print(e.message);
          },
          codeSent: (String verificationId, [int forceResendingToken]) async {
            this._verificationId = verificationId;
            showSnackbar(_scaffoldKey, 'Code sent');
            codeSentCallback();
            print('Code Sent');
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            this._verificationId = verificationId;
            print(this._verificationId);
          });
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logIn(GlobalKey<ScaffoldState> _scaffoldKey, String smsCode) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: this._verificationId, smsCode: smsCode);
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User user = userCredential.user;
      if (user == null) {
        print("Could not login 111");
      }
      return user;
    } catch (e) {
      print(e.message);
      // _scaffoldKey.currentState
      //     .showSnackBar(SnackBar(content: Text(e.message)));
    }
    // } catch (e) {
    //   print('Could not login');
    //   print(e.toString());
    //   return null;
    // }
  }

  Future signout() async {
    try {
      return await _auth.signOut().then((value) => Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Wrapper())));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream<User> get user {
    return _auth.authStateChanges();
  }
}
