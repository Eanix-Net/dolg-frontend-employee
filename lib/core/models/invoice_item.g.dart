// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
      id: (json['id'] as num?)?.toInt(),
      invoiceId: (json['invoice_id'] as num).toInt(),
      serviceId: (json['service_id'] as num).toInt(),
      cost: (json['cost'] as num).toDouble(),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'service_id': instance.serviceId,
      'cost': instance.cost,
      'service': instance.service,
    };
