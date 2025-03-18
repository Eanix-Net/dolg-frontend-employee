// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      notes: json['notes'] as String?,
      createdDateTime: json['created_datetime'] == null
          ? null
          : DateTime.parse(json['created_datetime'] as String),
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => CustomerLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'notes': instance.notes,
      'created_datetime': instance.createdDateTime?.toIso8601String(),
      'locations': instance.locations,
    };
