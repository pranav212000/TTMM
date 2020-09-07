import 'package:flutter/cupertino.dart';
import 'package:ttmm/models/user.dart';

class Group {
  String groupId;
  String groupName;
  String groupIconUrl;
  List<UserData> groupMembers;

  Group(
      {@required this.groupId,
      @required this.groupName,
      @required this.groupMembers,
      this.groupIconUrl});
}
