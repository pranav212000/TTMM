// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    orderId: json['orderId'] as String,
    eventId: json['eventId'] as String,
    phoneNumber: json['phoneNumber'] as List,
    itemName: json['itemName'] as String,
    quantity: json['quantity'] as int,
    cost: json['cost'] as int,
    totalCost: json['totalCost'] as int,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'eventId': instance.eventId,
      'phoneNumber': instance.phoneNumber,
      'itemName': instance.itemName,
      'quantity': instance.quantity,
      'cost': instance.cost,
      'totalCost': instance.totalCost,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
