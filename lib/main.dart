import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ttmm/services/auth.dart';
import 'package:ttmm/shared/error.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:ttmm/wrapper.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: ErrorScreen(),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
              iconTheme: IconThemeData(
                color: Colors.blue,
              ),
            ),

            home: StreamProvider<User>.value(
                value: AuthService().user, child: Wrapper()),
            // home: SignIn(),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Loading(),
        );
      },
    );
  }
}
