import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer_location.dart';

part 'appointment.g.dart';

/// Appointment model representing a scheduled appointment
@JsonSerializable()
class Appointment implements BaseModel {
  /// Appointment ID
  final int? id;
  
  /// ID of the customer location for this appointment
  @JsonKey(name: 'customer_location_id')
  final int customerLocationId;
  
  /// Date and time of arrival
  @JsonKey(name: 'arrival_datetime')
  final DateTime arrivalDateTime;
  
  /// Date and time of departure
  @JsonKey(name: 'departure_datetime')
  final DateTime departureDateTime;
  
  /// Team assigned to this appointment
  final String? team;
  
  /// Customer location details
  final CustomerLocation? location;
  
  /// Customer name (for display purposes)
  @JsonKey(name: 'customer_name')
  final String? customerName;
  
  /// Address (for display purposes)
  final String? address;

  /// Constructor
  Appointment({
    this.id,
    required this.customerLocationId,
    required this.arrivalDateTime,
    required this.departureDateTime,
    this.team,
    this.location,
    this.customerName,
    this.address,
  });

  /// Create Appointment from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  /// Convert Appointment to JSON
  @override
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  /// Create a copy of Appointment with updated fields
  @override
  Appointment copyWith({
    int? id,
    int? customerLocationId,
    DateTime? arrivalDateTime,
    DateTime? departureDateTime,
    String? team,
    CustomerLocation? location,
    String? customerName,
    String? address,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerLocationId: customerLocationId ?? this.customerLocationId,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      team: team ?? this.team,
      location: location ?? this.location,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
    );
  }
} 