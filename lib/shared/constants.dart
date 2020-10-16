import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    hoverColor: Colors.cyan,
    // enabledBorder: OutlineInputBorder(
    //     borderSide: BorderSide(color: Colors.amber, width: 2.0)),
    // focusedBorder: OutlineInputBorder(
    //     borderSide: BorderSide(color: Colors.deepPurple, width: 2.0,)),

    labelStyle: TextStyle(color: Colors.deepPurple));

void showSnackbar(GlobalKey<ScaffoldState> _scaffoldKey, String text,
    {Color color}) {
  if (color == null) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
    ));
  } else {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color,
    ));
  }
}

String formatDate(DateTime dateTime) {
  String date;
  Duration difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) {
    date = 'now';
  } else if (difference.inMinutes < 60) {
    date = difference.inMinutes.toString() + 'min ago';
  } else if (difference.inHours < 24) {
    date = difference.inHours.toString() + 'h ago';
  } else if (difference.inDays < 30) {
    date = difference.inDays.toString() + 'days ago';
  } else {
    date = dateTime.day.toString() +
        '/' +
        dateTime.month.toString() +
        '/' +
        dateTime.year.toString();
  }
  return date;
}

const currentUser = 'currentuser';
const currentPhoneNUmber = 'currentPhoneNumber';
const phoneNumber = 'phoneNumber';
const groups = 'groups';
const groupId = 'groupId';
const groupName = 'groupName';
const groupIconUrl = 'groupIconUrl';
const groupMembers = 'members';
const updateTime = 'updateTime';
const createdTime = 'createdTime';
const split = 'split';
const String evenly = 'evenly';
const String byOrder = 'byOrder';
const String paymentMode = 'paymentMode';
const String amount = 'amount';
const String cash = 'cash';
const String upi = 'upi';
const String to = 'to';