// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
      transactionId: json['transactionId'],
      split: json['split'],
      toGet: (json['toGet'] as List)
          ?.map((e) => e as Map<String, dynamic>)
          ?.toList(),
      toGive: (json['toGive'] as List)
          ?.map((e) => e as Map<String, dynamic>)
          ?.toList(),
      got: (json['got'] as List)
          ?.map((e) => e as Map<String, dynamic>)
          ?.toList(),
      given: (json['given'] as List)
          ?.map((e) => e as Map<String, dynamic>)
          ?.toList(),
      totalCost: json['totalCost'] as int,
      totalPaid: json['totalPaid'] as int,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String))
    ..paid =
        (json['paid'] as List)?.map((e) => e as Map<String, dynamic>)?.toList();
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'split': instance.split,
      'toGet': instance.toGet,
      'toGive': instance.toGive,
      'got': instance.got,
      'given': instance.given,
      'paid': instance.paid,
      'totalCost': instance.totalCost,
      'totalPaid': instance.totalPaid,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String()
    };
