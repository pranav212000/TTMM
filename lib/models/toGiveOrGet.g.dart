// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toGiveOrGet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToGiveOrGet _$ToGiveOrGetFromJson(Map<String, dynamic> json) {
  return ToGiveOrGet(
      phoneNumber: json['phoneNumber'],
      amount: json['amount'] as int,
      eventId: json['eventId'],
      eventName: json['eventName']);
}

Map<String, dynamic> _$ToGiveOrGetToJson(ToGiveOrGet instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'amount': instance.amount,
      'eventId': instance.eventId,
      'eventName': instance.eventName
    };
