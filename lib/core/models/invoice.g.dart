// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      id: (json['id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num).toDouble(),
      paid: $enumDecode(_$PaymentStatusEnumMap, json['paid']),
      attempt: (json['attempt'] as num).toInt(),
      dueDate: DateTime.parse(json['due_date'] as String),
      createdDate: json['created_date'] == null
          ? null
          : DateTime.parse(json['created_date'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'subtotal': instance.subtotal,
      'total': instance.total,
      'tax_rate': instance.taxRate,
      'paid': _$PaymentStatusEnumMap[instance.paid]!,
      'attempt': instance.attempt,
      'due_date': instance.dueDate.toIso8601String(),
      'created_date': instance.createdDate?.toIso8601String(),
      'items': instance.items,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.declined: 'declined',
};
