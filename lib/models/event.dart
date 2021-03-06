import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  String eventId;
  String eventName;
  String transactionId;
  List<dynamic> orders;
  DateTime createdAt;
  DateTime updatedAt;

  Event(
      {@required this.eventId,
      @required this.eventName,
      @required this.transactionId,
      this.orders = const [],
      this.createdAt,
      this.updatedAt});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
