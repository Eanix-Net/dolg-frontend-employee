// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentCategory _$EquipmentCategoryFromJson(Map<String, dynamic> json) =>
    EquipmentCategory(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$EquipmentCategoryToJson(EquipmentCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
