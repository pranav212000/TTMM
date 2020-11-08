import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/fcm/fcm.dart';
import 'package:ttmm/fcm/notification_manager.dart';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:ttmm/models/group.dart';
import 'package:ttmm/navigator.dart';
import 'package:ttmm/screens/authenticate/signin.dart';
import 'package:ttmm/screens/event/event_home.dart';
import 'package:ttmm/screens/grouphome/addgroup.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/firebase_api_service.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';

import 'models/userdata.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  Future<List<Group>> getGroups() async {
    print("CURRENT TIME :");
    print(Timestamp.fromDate(DateTime.now()));

    List<dynamic> groupIds = new List<dynamic>();

    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');
    groupIds.add('6c760bf0-f2a6-11ea-afc1-9f5ccda2294b');

    return await DatabaseService().getUserGroups(groupIds);
  }

  Future<UserData> _getUserData(firebaseAuth.User firebaseuser) async {
    Response response = await UserApiService.create().getUser(firebaseuser.uid);

    if (response.statusCode == 200) {
      UserData userData = UserData.fromJson(response.body);
      print('USER DATA FROM API : ');
      print(userData.toJson());
      return userData;
    } else {
      print('User not found!');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void initFirebase() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsFlutterBinding.ensureInitialized();

      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

      NotificationManger.init(context: context);
      Fcm.initConfigure(context);
      // _firebaseMessaging.configure(
      //   onBackgroundMessage: Platform.isIOS
      //       ? null
      //       : NotificationManger.myBackgroundMessageHandler,
      //   onMessage: (message) async {

      //     print("onMessage: $message");
      //   },
      //   onLaunch: (message) async {
      //     print("onLaunch: $message");
      //   },
      //   onResume: (message) async {
      //     print("onResume: $message");
      //   },
      // );

      _firebaseMessaging.getToken().then((String token) {
        print("Push Messaging token: $token");
        // Push messaging to this token later
      });
      // NotificationManger.init(context: context);

      // Fcm.initConfigure();
    });
  }

  // Future<String> onSelect(String data) async {
  //   print("onSelectNotification $data");
  // }

  // Future<dynamic> myBackgroundMessageHandler(
  //     Map<String, dynamic> message) async {
  //   print("myBackgroundMessageHandler message: $message");
  //   int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  //   print("msgId $msgId");
  //   // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //   //     'fcm_default_channel', 'fcm_default_channel', 'fcm_default_channel',
  //   //     color: Colors.blue.shade800,
  //   //     importance: Importance.max,
  //   //     priority: Priority.max,
  //   //     ticker: 'ticker');
  //   // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   // var platformChannelSpecifics = NotificationDetails(
  //   //     android: androidPlatformChannelSpecifics,
  //   //     iOS: iOSPlatformChannelSpecifics);
  //   // flutterLocalNotificationsPlugin.show(0, message['notification']['title'],
  //   //     message["notification"]["body"], platformChannelSpecifics,
  //   //     payload: "Task");
  //   _showNotification(message);
  //   return Future<void>.value();
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<firebaseAuth.User>(context);
    if (user == null)
      return SignIn();
    else {
      initFirebase();
      setSharedPreferences(user);
      return NavigatorPage();
    }
// // TODO fix this jugad!
//     else {
//       setSharedPreferences(user);
//       return EventHome();
//     }
  }

  void setSharedPreferences(firebaseAuth.User user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(currentUser, user.uid);
    preferences.setString(currentPhoneNUmber, user.phoneNumber);
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token = await _firebaseMessaging.getToken();
    print("token : $token");
    preferences.setString(FCM_TOKEN, token);

    Map<String, dynamic> body = {
      'phoneNumber': user.phoneNumber,
      'token': token
    };
    Response response = await FirebaseApiService.create().storeToken(body);
    print(response.body);
  }
}
