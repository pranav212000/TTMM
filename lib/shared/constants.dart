import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  hoverColor: Colors.cyan,
  // enabledBorder: OutlineInputBorder(
  //     borderSide: BorderSide(color: Colors.amber, width: 2.0)),
  // focusedBorder: OutlineInputBorder(
  //     borderSide: BorderSide(color: Colors.deepPurple, width: 2.0,)),
  
  labelStyle: TextStyle(color: Colors.deepPurple)
);

void showSnackbar(GlobalKey<ScaffoldState> _scaffoldKey, String text) {
  _scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Text(text),
  ));
}

const currentUser = 'currentuser';
const currentPhoneNUmber = 'currentPhoneNumber';
const groups = 'groups';
const groupId = 'groupId';
const groupName = 'groupName';
const groupIconUrl = 'groupIconUrl';
const groupMembers = 'members';
const updateTime = 'updateTime';
const createdTime = 'createdTime';
