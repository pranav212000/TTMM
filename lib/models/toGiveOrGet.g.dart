// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toGiveOrGet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToGiveOrGet _$ToGiveOrGetFromJson(Map<String, dynamic> json) {
  return ToGiveOrGet(
    phoneNumber: json['phoneNumber'] as String,
    amount: json['amount'] as int,
    name: json['name'] as String,
    eventId: json['eventId'] as String,
    eventName: json['eventName'] as String,
  );
}

Map<String, dynamic> _$ToGiveOrGetToJson(ToGiveOrGet instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'name': instance.name,
      'amount': instance.amount,
      'eventId': instance.eventId,
      'eventName': instance.eventName,
    };
