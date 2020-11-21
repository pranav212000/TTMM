import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';

part 'given_or_got.g.dart';

@JsonSerializable()
class GivenOrGot {
  String phoneNumber;
  String name;
  int amount;
  String eventId;
  String eventName;
  String paymentMode;
  String time;

  GivenOrGot(
      {@required this.phoneNumber,
      @required this.amount,
      this.name,
      this.eventId,
      this.eventName,
      this.paymentMode,
      this.time});

  factory GivenOrGot.fromJson(Map<String, dynamic> json) =>
      _$GivenOrGotFromJson(json);

  Map<String, dynamic> toJson() => _$GivenOrGotToJson(this);
}
