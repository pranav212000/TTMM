import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  String transactionId;
  String split;
  List<Map<String, dynamic>> toGet;
  List<Map<String, dynamic>> toGive;
  // List<Map<String, dynamic>> got;
  List<Map<String, dynamic>> given;
  List<Map<String, dynamic>> paid;
  int totalCost;
  int totalPaid;
  DateTime createdAt;
  DateTime updatedAt;

  Transaction(
      {@required this.transactionId,
      @required this.split,
      @required this.toGet,
      @required this.toGive,
      // @required this.got,
      @required this.given,
      @required this.totalCost,
      @required this.totalPaid,
      this.paid,
      this.createdAt,
      this.updatedAt});

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
