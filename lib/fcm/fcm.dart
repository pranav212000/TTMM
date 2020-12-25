import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ttmm/fcm/notification_manager.dart';
import 'package:ttmm/services/firebase_api_service.dart';

class Fcm {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static initConfigure(BuildContext context) {
    if (Platform.isIOS) _iosPermission();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.autoInitEnabled();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        NotificationManager.showNotification(message);
        print('onMessage $message');
        NotificationManager.handleNotificationMsg(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('ON LAUNCH');
        NotificationManager.handleDataMsg(message['data']);
      },
      onResume: (Map<String, dynamic> message) async {
        WidgetsFlutterBinding.ensureInitialized();
        final dynamic data = message['data'];
        //as ex we have some data json for every notification to know how to handle that
        //let say showDialog here so fire some action
        if (data.containsKey('showDialog')) {
          // Handle data message with dialog
          print(data);
          print('SHOWING DIALOG');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(message['data']['title'],
                      style: GoogleFonts.josefinSans()),
                  content: Text(message['data']['body'],
                      style: GoogleFonts.josefinSans()),
                  actions: [
                    FlatButton(
                        onPressed: () async {
                          FirebaseApiService.create()
                              .sendNotGotCash(data['paymentId'])
                              .then((value) {
                            Fluttertoast.showToast(
                                msg: "Response sent",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.tealAccent,
                                textColor: Colors.black,
                                fontSize: 16.0);
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text('No', style: GoogleFonts.josefinSans())),
                    FlatButton(
                      onPressed: () async {
                        NotificationManager.postPayPerson(
                            data['phoneNumber'],
                            data['eventId'],
                            int.parse(data['amount']),
                            'cash',
                            data['to'],
                            data['paymentId']);
                        Navigator.of(context).pop();
                      },
                      child: Text('Yes', style: GoogleFonts.josefinSans()),
                    )
                  ],
                );
              });
          print('ON RESUME');
          print(message);
          // showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: Text('Alert'),
          //         content: Text('ON RESUME'),
          //       );
          //     });
          // NotificationManager.handleDataMsg(message['data']);
        }
      },
      onBackgroundMessage: Platform.isIOS
          ? null
          : NotificationManager.myBackgroundMessageHandler,
    );
  }

  static _iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
