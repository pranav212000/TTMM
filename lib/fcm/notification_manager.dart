import 'package:flutter/material.dart';

class NotificationManger {
  static BuildContext _context;

  static init({@required BuildContext context}) {
    _context = context;
  }

  //this method used when notification come and app is closed or in background and
  // user click on it, i will left it empty for you
  static handleDataMsg(Map<String, dynamic> data) {
    if (data.containsKey('showDialog')) {
      // Handle data message with dialog
      _showDialog(data);
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
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  static _showDialog(Map<String, dynamic> data) async {
    print('IN SHOW DIALOG');
    showDialog(
        context: _context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text('Alert content'),
          );
        });
  }

  //this our method called when notification come and app is foreground
  static handleNotificationMsg(Map<String, dynamic> message) {
    print("from mangger  $message");

    final dynamic data = message['data'];
    //as ex we have some data json for every notification to know how to handle that
    //let say showDialog here so fire some action
    if (data.containsKey('showDialog')) {
      // Handle data message with dialog
      print('SHOWING DIALOG');
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
