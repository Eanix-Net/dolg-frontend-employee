import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'equipment_category.dart';

part 'equipment.g.dart';

/// Equipment condition types
enum EquipmentCondition {
  @JsonValue('New')
  newCondition,
  @JsonValue('Used')
  usedCondition
}

/// Fuel types for equipment
enum FuelType {
  @JsonValue('Gas')
  gas,
  @JsonValue('Diesel')
  diesel,
  @JsonValue('Electric')
  electric
}

/// Equipment model representing a piece of equipment
@JsonSerializable()
class Equipment implements BaseModel {
  /// Equipment ID
  final int? id;
  
  /// Equipment name
  final String name;
  
  /// Date when the equipment was purchased
  @JsonKey(name: 'purchased_date')
  final DateTime? purchasedDate;
  
  /// Condition when purchased (new or used)
  @JsonKey(name: 'purchased_condition')
  final EquipmentCondition? purchasedCondition;
  
  /// Date when the warranty expires
  @JsonKey(name: 'warranty_expiration_date')
  final DateTime? warrantyExpirationDate;
  
  /// Equipment manufacturer
  final String? manufacturer;
  
  /// Equipment model
  final String? model;
  
  /// ID of the equipment category
  @JsonKey(name: 'equipment_category_id')
  final int? equipmentCategoryId;
  
  /// Purchase price
  @JsonKey(name: 'purchase_price')
  final double? purchasePrice;
  
  /// Total repair costs to date
  @JsonKey(name: 'repair_cost_to_date')
  final double? repairCostToDate;
  
  /// Who purchased the equipment
  @JsonKey(name: 'purchased_by')
  final String? purchasedBy;
  
  /// Type of fuel used
  @JsonKey(name: 'fuel_type')
  final FuelType? fuelType;
  
  /// Type of oil used
  @JsonKey(name: 'oil_type')
  final String? oilType;
  
  /// Date when the equipment was created in the system
  @JsonKey(name: 'created_date')
  final DateTime? createdDate;
  
  /// Equipment category details
  final EquipmentCategory? category;

  /// Constructor
  Equipment({
    this.id,
    required this.name,
    this.purchasedDate,
    this.purchasedCondition,
    this.warrantyExpirationDate,
    this.manufacturer,
    this.model,
    this.equipmentCategoryId,
    this.purchasePrice,
    this.repairCostToDate,
    this.purchasedBy,
    this.fuelType,
    this.oilType,
    this.createdDate,
    this.category,
  });

  /// Create Equipment from JSON
  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);

  /// Convert Equipment to JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);

  /// Create a copy of Equipment with updated fields
  @override
  Equipment copyWith({
    int? id,
    String? name,
    DateTime? purchasedDate,
    EquipmentCondition? purchasedCondition,
    DateTime? warrantyExpirationDate,
    String? manufacturer,
    String? model,
    int? equipmentCategoryId,
    double? purchasePrice,
    double? repairCostToDate,
    String? purchasedBy,
    FuelType? fuelType,
    String? oilType,
    DateTime? createdDate,
    EquipmentCategory? category,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      purchasedCondition: purchasedCondition ?? this.purchasedCondition,
      warrantyExpirationDate: warrantyExpirationDate ?? this.warrantyExpirationDate,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      equipmentCategoryId: equipmentCategoryId ?? this.equipmentCategoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      repairCostToDate: repairCostToDate ?? this.repairCostToDate,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      fuelType: fuelType ?? this.fuelType,
      oilType: oilType ?? this.oilType,
      createdDate: createdDate ?? this.createdDate,
      category: category ?? this.category,
    );
  }
} 