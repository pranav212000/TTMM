import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Group {
  String groupId;
  String groupName;
  String groupIconUrl;
  Timestamp updateTime;
  Timestamp createdTime;
  List<dynamic> groupMembers;

  Group(
      {@required this.groupId,
      @required this.groupName,
      @required this.groupMembers,
      @required this.updateTime,
      @required this.createdTime,
      this.groupIconUrl});
}
