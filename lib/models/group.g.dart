// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) {
  return Group(
      groupId: json['groupId'],
      groupName: json['groupName'],
      groupMembers: json['groupMembers'] as List,
      groupIconUrl: json['groupIconUrl']);
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'groupIconUrl': instance.groupIconUrl,
      'groupMembers': instance.groupMembers
    };
