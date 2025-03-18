// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      id: (json['id'] as num?)?.toInt(),
      customerLocationId: (json['customer_location_id'] as num).toInt(),
      arrivalDateTime: DateTime.parse(json['arrival_datetime'] as String),
      departureDateTime: DateTime.parse(json['departure_datetime'] as String),
      team: json['team'] as String?,
      location: json['location'] == null
          ? null
          : CustomerLocation.fromJson(json['location'] as Map<String, dynamic>),
      customerName: json['customer_name'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_location_id': instance.customerLocationId,
      'arrival_datetime': instance.arrivalDateTime.toIso8601String(),
      'departure_datetime': instance.departureDateTime.toIso8601String(),
      'team': instance.team,
      'location': instance.location,
      'customer_name': instance.customerName,
      'address': instance.address,
    };
