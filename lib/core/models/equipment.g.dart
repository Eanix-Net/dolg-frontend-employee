// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      purchasedDate: json['purchased_date'] == null
          ? null
          : DateTime.parse(json['purchased_date'] as String),
      purchasedCondition: $enumDecodeNullable(
          _$EquipmentConditionEnumMap, json['purchased_condition']),
      warrantyExpirationDate: json['warranty_expiration_date'] == null
          ? null
          : DateTime.parse(json['warranty_expiration_date'] as String),
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      equipmentCategoryId: (json['equipment_category_id'] as num?)?.toInt(),
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      repairCostToDate: (json['repair_cost_to_date'] as num?)?.toDouble(),
      purchasedBy: json['purchased_by'] as String?,
      fuelType: $enumDecodeNullable(_$FuelTypeEnumMap, json['fuel_type']),
      oilType: json['oil_type'] as String?,
      createdDate: json['created_date'] == null
          ? null
          : DateTime.parse(json['created_date'] as String),
      category: json['category'] == null
          ? null
          : EquipmentCategory.fromJson(
              json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'purchased_date': instance.purchasedDate?.toIso8601String(),
      'purchased_condition':
          _$EquipmentConditionEnumMap[instance.purchasedCondition],
      'warranty_expiration_date':
          instance.warrantyExpirationDate?.toIso8601String(),
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'equipment_category_id': instance.equipmentCategoryId,
      'purchase_price': instance.purchasePrice,
      'repair_cost_to_date': instance.repairCostToDate,
      'purchased_by': instance.purchasedBy,
      'fuel_type': _$FuelTypeEnumMap[instance.fuelType],
      'oil_type': instance.oilType,
      'created_date': instance.createdDate?.toIso8601String(),
      'category': instance.category,
    };

const _$EquipmentConditionEnumMap = {
  EquipmentCondition.newCondition: 'New',
  EquipmentCondition.usedCondition: 'Used',
};

const _$FuelTypeEnumMap = {
  FuelType.gas: 'Gas',
  FuelType.diesel: 'Diesel',
  FuelType.electric: 'Electric',
};
