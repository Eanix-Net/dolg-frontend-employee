import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer_location.dart';

part 'customer.g.dart';

/// Customer model representing a customer in the system
@JsonSerializable()
class Customer implements BaseModel {
  /// Customer ID
  final int? id;
  
  /// Customer name
  final String name;
  
  /// Customer phone number
  final String? phone;
  
  /// Customer email address
  final String email;
  
  /// Additional notes about the customer
  final String? notes;
  
  /// Date and time when the customer was created
  @JsonKey(name: 'created_datetime')
  final DateTime? createdDateTime;
  
  /// Customer locations
  final List<CustomerLocation>? locations;

  /// Constructor
  Customer({
    this.id,
    required this.name,
    this.phone,
    required this.email,
    this.notes,
    this.createdDateTime,
    this.locations,
  });

  /// Create Customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

  /// Convert Customer to JSON
  @override
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  /// Create a copy of Customer with updated fields
  @override
  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    DateTime? createdDateTime,
    List<CustomerLocation>? locations,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      locations: locations ?? this.locations,
    );
  }
} 