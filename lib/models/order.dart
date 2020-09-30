import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  String orderId;
  String eventId;
  List<dynamic> phoneNumber;
  String itemName;
  int quantity;
  int cost;
  int totalCost;
  DateTime createdAt;
  DateTime updatedAt;

  Order(
      {@required this.orderId,
      @required this.eventId,
      @required this.phoneNumber,
      @required this.itemName,
      @required this.quantity,
      @required this.cost,
      @required this.totalCost,
      this.createdAt,
      this.updatedAt});

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
