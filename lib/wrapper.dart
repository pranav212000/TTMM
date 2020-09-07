import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttmm/screens/authenticate/signin.dart';
import 'package:ttmm/screens/home/home.dart';

class Wrapper extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null)
      return SignIn();
    else
      return Home();
      
  }
}