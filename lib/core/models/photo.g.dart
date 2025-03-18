// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: (json['id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      filePath: json['file_path'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      showToCustomer: json['show_to_customer'] as bool?,
      showOnWebsite: json['show_on_website'] as bool?,
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'file_path': instance.filePath,
      'uploaded_by': instance.uploadedBy,
      'approved_by': instance.approvedBy,
      'show_to_customer': instance.showToCustomer,
      'show_on_website': instance.showOnWebsite,
      'datetime': instance.datetime?.toIso8601String(),
    };
