import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  String groupId;
  String groupName;
  String groupIconUrl;
  DateTime updatedAt;
  DateTime createdAt;
  List<dynamic> groupMembers;

  Group(
      {@required this.groupId,
      @required this.groupName,
      @required this.groupMembers,
      this.updatedAt,
      this.createdAt,
      this.groupIconUrl});

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
