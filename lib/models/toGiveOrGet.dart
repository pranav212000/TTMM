import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';

part 'toGiveOrGet.g.dart';

@JsonSerializable()
class ToGiveOrGet {
  String phoneNumber;
  int amount;
  String eventId;
  String eventName;

  ToGiveOrGet(
      {@required this.phoneNumber,
      @required this.amount,
      this.eventId,
      this.eventName});

  factory ToGiveOrGet.fromJson(Map<String, dynamic> json) =>
      _$ToGiveOrGetFromJson(json);

  Map<String, dynamic> toJson() => _$ToGiveOrGetToJson(this);
}
