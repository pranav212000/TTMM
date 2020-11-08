import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ttmm/screens/contacts/contacts_page.dart';
import 'package:ttmm/screens/home/home.dart';

import 'package:ttmm/services/auth.dart';
import 'package:ttmm/shared/error.dart';
import 'package:ttmm/shared/loading.dart';
import 'package:ttmm/wrapper.dart';
import 'package:logging/logging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  _setUpLogging();
  WidgetsFlutterBinding.ensureInitialized();

  // var initializationSettingsAndroid =
  //     AndroidInitializationSettings('ic_launcher');

  // var initializationSettingsIOS = IOSInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //     onDidReceiveLocalNotification:
  //         (int id, String title, String body, String payload) async {});

  // var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: (String payload) async {
  //   print('ON SELECT NOTIFIACTION : ' + payload);
  //   if (payload != null) {
  //     print('notification payload : ' + payload);
  //   }
  // });

  runApp(App());
}

void _setUpLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('${rec.level.name} : ${rec.time} : ${rec.message}');
  });
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
          return StreamProvider<User>.value(
            value: AuthService().user,
            child: MaterialApp(
              theme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.orange,
                primaryTextTheme: GoogleFonts.ralewayTextTheme(
                    Theme.of(context).primaryTextTheme),
                textTheme: GoogleFonts.ralewayTextTheme(Theme.of(context)
                    .textTheme
                    .apply(
                        bodyColor: Colors.white, displayColor: Colors.white)),
                iconTheme: IconThemeData(
                  color: Colors.orange,
                ),
              ),
              home: Wrapper(),
              // home: SignIn(),
            ),
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

void setFirebase() {}
