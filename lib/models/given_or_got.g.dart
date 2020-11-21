// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'given_or_got.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GivenOrGot _$GivenOrGotFromJson(Map<String, dynamic> json) {
  return GivenOrGot(
    phoneNumber: json['phoneNumber'] as String,
    amount: json['amount'] as int,
    name: json['name'] as String,
    eventId: json['eventId'] as String,
    eventName: json['eventName'] as String,
    paymentMode: json['paymentMode'] as String,
    time: json['time'] as String,
  );
}

Map<String, dynamic> _$GivenOrGotToJson(GivenOrGot instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'name': instance.name,
      'amount': instance.amount,
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'paymentMode': instance.paymentMode,
      'time': instance.time,
    };
