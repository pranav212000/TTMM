// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userdata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return UserData(
      uid: json['uid'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      groups: json['groups'] as List,
      profileUrl: json['profileUrl']);
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'groups': instance.groups,
      'profileUrl': instance.profileUrl
    };
