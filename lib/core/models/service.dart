import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'service.g.dart';

/// Service model representing a service offered by the company
@JsonSerializable()
class Service implements BaseModel {
  /// Service ID
  final int? id;
  
  /// Service name
  final String name;
  
  /// Service description
  final String? description;

  /// Constructor
  Service({
    this.id,
    required this.name,
    this.description,
  });

  /// Create Service from JSON
  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

  /// Convert Service to JSON
  @override
  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  /// Create a copy of Service with updated fields
  @override
  Service copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
} 