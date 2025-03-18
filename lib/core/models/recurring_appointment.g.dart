// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringAppointment _$RecurringAppointmentFromJson(
        Map<String, dynamic> json) =>
    RecurringAppointment(
      id: (json['id'] as num?)?.toInt(),
      customerLocationId: (json['customer_location_id'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      schedule: json['schedule'] as String,
      team: json['team'] as String?,
      location: json['location'] == null
          ? null
          : CustomerLocation.fromJson(json['location'] as Map<String, dynamic>),
      customerName: json['customer_name'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$RecurringAppointmentToJson(
        RecurringAppointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_location_id': instance.customerLocationId,
      'start_date': instance.startDate.toIso8601String(),
      'schedule': instance.schedule,
      'team': instance.team,
      'location': instance.location,
      'customer_name': instance.customerName,
      'address': instance.address,
    };
