import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'equipment_category.g.dart';

/// EquipmentCategory model representing a category of equipment
@JsonSerializable()
class EquipmentCategory implements BaseModel {
  /// EquipmentCategory ID
  final int? id;
  
  /// Category name
  final String name;

  /// Constructor
  EquipmentCategory({
    this.id,
    required this.name,
  });

  /// Create EquipmentCategory from JSON
  factory EquipmentCategory.fromJson(Map<String, dynamic> json) => _$EquipmentCategoryFromJson(json);

  /// Convert EquipmentCategory to JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentCategoryToJson(this);

  /// Create a copy of EquipmentCategory with updated fields
  @override
  EquipmentCategory copyWith({
    int? id,
    String? name,
  }) {
    return EquipmentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
} 