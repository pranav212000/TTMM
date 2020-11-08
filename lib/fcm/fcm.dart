import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttmm/fcm/notification_manager.dart';

class Fcm {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  static initConfigure(BuildContext context) {
    if (Platform.isIOS) _iosPermission();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.autoInitEnabled();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        NotificationManger.showNotification(message);
        print('onMessage $message');
        NotificationManger.handleNotificationMsg(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('ON LAUNCH');
        NotificationManger.handleDataMsg(message['data']);
      },
      onResume: (Map<String, dynamic> message) async {
        WidgetsFlutterBinding.ensureInitialized();

        print('ON RESUME');
        print(message);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert'),
                content: Text('ON RESUME'),
              );
            });
        NotificationManger.handleDataMsg(message['data']);
      },
      onBackgroundMessage:
          Platform.isIOS ? null : NotificationManger.myBackgroundMessageHandler,
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
