// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteItem _$QuoteItemFromJson(Map<String, dynamic> json) => QuoteItem(
      id: (json['id'] as num?)?.toInt(),
      quoteId: (json['quote_id'] as num).toInt(),
      serviceId: (json['service_id'] as num).toInt(),
      cost: (json['cost'] as num).toDouble(),
      service: json['service'] == null
          ? null
          : Service.fromJson(json['service'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuoteItemToJson(QuoteItem instance) => <String, dynamic>{
      'id': instance.id,
      'quote_id': instance.quoteId,
      'service_id': instance.serviceId,
      'cost': instance.cost,
      'service': instance.service,
    };
