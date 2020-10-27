import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:ttmm/fcm/notification_manager.dart';

class Fcm {
  static final FirebaseMessaging _fcm = FirebaseMessaging();

  
  static initConfigure() {
    if (Platform.isIOS) _iosPermission();

    _fcm.requestNotificationPermissions();
    _fcm.autoInitEnabled();

    _fcm.configure(
        onMessage: (Map<String, dynamic> message) async =>
            NotificationManger.handleNotificationMsg(message),
        onLaunch: (Map<String, dynamic> message) async =>
            NotificationManger.handleDataMsg(message['data']),
        onResume: (Map<String, dynamic> message) async =>
            NotificationManger.handleDataMsg(message['data']),
        onBackgroundMessage: NotificationManger.myBackgroundMessageHandler
        );
  }

  static _iosPermission() {
    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
