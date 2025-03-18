// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerLocation _$CustomerLocationFromJson(Map<String, dynamic> json) =>
    CustomerLocation(
      id: (json['id'] as num?)?.toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      address: json['address'] as String?,
      pointOfContact: json['point_of_contact'] as String?,
      propertyType:
          $enumDecodeNullable(_$PropertyTypeEnumMap, json['property_type']),
      approxAcres: (json['approx_acres'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CustomerLocationToJson(CustomerLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'address': instance.address,
      'point_of_contact': instance.pointOfContact,
      'property_type': _$PropertyTypeEnumMap[instance.propertyType],
      'approx_acres': instance.approxAcres,
      'notes': instance.notes,
    };

const _$PropertyTypeEnumMap = {
  PropertyType.business: 'Business',
  PropertyType.residential: 'Residential',
};
