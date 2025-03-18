import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'customer_location.g.dart';

/// Property types for customer locations
enum PropertyType {
  @JsonValue('Business')
  business,
  @JsonValue('Residential')
  residential
}

/// CustomerLocation model representing a location associated with a customer
@JsonSerializable()
class CustomerLocation implements BaseModel {
  /// Location ID
  final int? id;
  
  /// ID of the customer this location belongs to
  @JsonKey(name: 'customer_id')
  final int customerId;
  
  /// Address of the location
  final String? address;
  
  /// Point of contact at this location
  @JsonKey(name: 'point_of_contact')
  final String? pointOfContact;
  
  /// Type of property (business or residential)
  @JsonKey(name: 'property_type')
  final PropertyType? propertyType;
  
  /// Approximate size of the property in acres
  @JsonKey(name: 'approx_acres')
  final double? approxAcres;
  
  /// Additional notes about the location
  final String? notes;

  /// Constructor
  CustomerLocation({
    this.id,
    required this.customerId,
    this.address,
    this.pointOfContact,
    this.propertyType,
    this.approxAcres,
    this.notes,
  });

  /// Create CustomerLocation from JSON
  factory CustomerLocation.fromJson(Map<String, dynamic> json) => _$CustomerLocationFromJson(json);

  /// Convert CustomerLocation to JSON
  @override
  Map<String, dynamic> toJson() => _$CustomerLocationToJson(this);

  /// Create a copy of CustomerLocation with updated fields
  @override
  CustomerLocation copyWith({
    int? id,
    int? customerId,
    String? address,
    String? pointOfContact,
    PropertyType? propertyType,
    double? approxAcres,
    String? notes,
  }) {
    return CustomerLocation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      address: address ?? this.address,
      pointOfContact: pointOfContact ?? this.pointOfContact,
      propertyType: propertyType ?? this.propertyType,
      approxAcres: approxAcres ?? this.approxAcres,
      notes: notes ?? this.notes,
    );
  }
} 