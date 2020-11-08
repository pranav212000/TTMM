import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ttmm/main.dart';
import 'package:ttmm/screens/profile/profile.dart';
import 'package:ttmm/services/firebase_api_service.dart';
import 'package:ttmm/services/transaction_api_service.dart';
import 'package:ttmm/shared/constants.dart';

class NotificationManger {
  static BuildContext _context;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  static init({@required BuildContext context}) {
    _context = context;
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // static Future<String> onSelect(String jsonData) async {
  //   print("onSelectNotification $jsonData");

  //   if (jsonData != null) {
  //     print('JSON DATA IS NOT NULL');
  //     Map<String, dynamic> data = jsonDecode(jsonData);
  //     print(data['id']);
  //     print(data['status']);
  //   }
  // }

  //this method used when notification come and app is closed or in background and
  // user click on it, i will left it empty for you
  static handleDataMsg(Map<String, dynamic> data) {
    print('IN HANDLE DATA MSG');
    print(data);
    if (data.containsKey('showDialog')) {
      // Handle data message with dialog
      print('SHOWING  data msg DIALOG');
      showDialog(
          context: _context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Alert content'),
            );
          });
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    print('BACKGROUND HANDLER');
    print(message);
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      if (data.containsKey('showDialog')) {
        // Handle data message with dialog
        Navigator.of(_context)
            .push(MaterialPageRoute(builder: (_) => Profile()));
        showDialog(
            context: _context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert'),
                content: Text('BACKGROUND DATA DIALOG'),
              );
            });
      }
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      // final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  // static _showDialog(Map<String, dynamic> data) async {
  //   print('IN SHOW DIALOG');
  //   showDialog(
  //       context: _context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Alert'),
  //           content: Text('Alert content'),
  //         );
  //       });
  // }

  //this our method called when notification come and app is foreground
  static handleNotificationMsg(Map<String, dynamic> message) {
    print("from manager  $message");
// {notification:
//  {title: Cash Confirmation,
//  body: You have a cash payment reconfirmation from test1 for amount 12},
//   data: {eventId: c2e7ca70-190a-11eb-b286-bb8b9555c574,
//   paymentId: 0758a010-190d-11eb-97f1-7dabe86cf733,
//   to: +911234567890,
//    body: Foreground message,
//     title: From POSTMAN,
//     showDialog: true,
//     reconfirmation: true}
//     }
    final dynamic data = message['data'];
    //as ex we have some data json for every notification to know how to handle that
    //let say showDialog here so fire some action
    if (data.containsKey('showDialog')) {
      // Handle data message with dialog
      print(data);
      print('SHOWING DIALOG');
      showDialog(
          context: _context,
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
                    postPayPerson(
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
    }
  }

  static postPayPerson(String phone, String eventId, int amt, String mode,
      String toPhone, String paymentId) async {
    Map<String, dynamic> body = {
      phoneNumber: phone,
      paymentMode: mode,
      amount: amt,
      to: toPhone,
      'paymentId': paymentId
    };
    try {
      Response response =
          await TransactionApiService.create().postPayPerson(eventId, body);
      Fluttertoast.showToast(
          msg: "Confirmed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.tealAccent,
          textColor: Colors.black,
          fontSize: 16.0);

      print(response.body);
    } catch (e) {
      Response response = e;
      Map<String, dynamic> map = json.decode(response.body);
      print(map["error"]);
    }
  }

  static Future showNotification(Map<String, dynamic> message) async {
    var androidDetails = new AndroidNotificationDetails(
        "fcm_default_channel", "fcm_default_channel", "fcm_default_channel",
        importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    print(message['notification']);
    print(message['data']);
    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'],
        message["notification"]["body"],
        generalNotificationDetails,
        payload: jsonEncode(message['data']));
  }

  // static _showDialog({@required Map<String, dynamic> data}) {
  //   //you can use data map also to know what must show in MyDialog
  //   showDialog(
  //       context: _context,
  //       builder: (_) => AlertDialog(
  //             title: Text(data.toString()),
  //             content: Text('CONTENT OF ALERT DIALOG'),
  //           ));
  // }
}
