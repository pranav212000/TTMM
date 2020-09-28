// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
      orderId: json['orderId'],
      eventId: json['eventId'],
      phoneNumber: json['phoneNumber'] as List,
      itemName: json['itemName'],
      quantity: json['quantity'] as int,
      cost: json['cost'] as int,
      totalCost: json['totalCost'] as int);
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'eventId': instance.eventId,
      'phoneNumber': instance.phoneNumber,
      'itemName': instance.itemName,
      'quantity': instance.quantity,
      'cost': instance.cost,
      'totalCost': instance.totalCost
    };
