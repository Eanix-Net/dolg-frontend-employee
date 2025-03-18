// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
      id: (json['id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      estimate: (json['estimate'] as num).toDouble(),
      employeeId: (json['employee_id'] as num).toInt(),
      createdDate: json['created_date'] == null
          ? null
          : DateTime.parse(json['created_date'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => QuoteItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'estimate': instance.estimate,
      'employee_id': instance.employeeId,
      'created_date': instance.createdDate?.toIso8601String(),
      'items': instance.items,
    };
