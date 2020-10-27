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

void main() async {
  _setUpLogging();
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      print('notification payload : ' + payload);
    }
  });

  runApp(App());
  setFirebase();
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

void setFirebase() {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('ic_launcher');

  var initializationSettingsIOS = IOSInitializationSettings();

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelect);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _firebaseMessaging.configure(
    onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
    onMessage: (message) async {
      _showNotification();
      print("onMessage: $message");
    },
    onLaunch: (message) async {
      print("onLaunch: $message");
    },
    onResume: (message) async {
      print("onResume: $message");
    },
  );

  _firebaseMessaging.getToken().then((String token) {
    print("Push Messaging token: $token");
    // Push messaging to this token later
  });
}

Future<String> onSelect(String data) async {
  print("onSelectNotification $data");
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  print("msgId $msgId");
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', 'fcm_default_channel', 'fcm_default_channel',
      color: Colors.blue.shade800,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(
      0, "TITLE", "THIS IS BODY OF NOTIFICATION", platformChannelSpecifics,
      payload: "Task");
  return Future<void>.value();
}

Future _showNotification() async {
  var androidDetails = new AndroidNotificationDetails(
      "fcm_default_channel", "fcm_default_channel", "fcm_default_channel",
      importance: Importance.max);
  var iSODetails = new IOSNotificationDetails();
  var generalNotificationDetails =
      new NotificationDetails(android: androidDetails, iOS: iSODetails);

  await flutterLocalNotificationsPlugin.show(
      0, "Task", "You created a Task", generalNotificationDetails,
      payload: "Task");
}
