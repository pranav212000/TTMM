import 'dart:ffi';
import 'dart:typed_data';
import 'package:floor/floor.dart';

@entity
class GroupEntity {
  @primaryKey
  final String groupId;
  final String groupName;
  final String groupIconUrl;
  final String updatedAt;
  final String createdAt;

  GroupEntity(
      {this.groupId,
      this.groupName,
      this.updatedAt,
      this.createdAt,
      this.groupIconUrl = ""});
}
