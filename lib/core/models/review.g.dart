// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num?)?.toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      locationId: (json['location_id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num?)?.toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
      customerName: json['customer_name'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'location_id': instance.locationId,
      'appointment_id': instance.appointmentId,
      'rating': instance.rating,
      'comment': instance.comment,
      'datetime': instance.datetime?.toIso8601String(),
      'customer_name': instance.customerName,
    };
