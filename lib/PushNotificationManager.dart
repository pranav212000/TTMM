import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();

      _firebaseMessaging.configure(
        onMessage: (msg) {
          print(msg);
        },
        onLaunch: (msg) {
          print(msg);
        },
        onResume: (msg) {
          print(msg);
        },
        onBackgroundMessage: (msg) {
          print(msg);
        },
      );
      String token = await _firebaseMessaging.getToken();

      // For testing purposes print the Firebase Messaging token
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }
}
