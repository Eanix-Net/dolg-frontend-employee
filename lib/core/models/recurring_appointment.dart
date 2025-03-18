import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer_location.dart';

part 'recurring_appointment.g.dart';

/// RecurringAppointment model representing a recurring scheduled appointment
@JsonSerializable()
class RecurringAppointment implements BaseModel {
  /// RecurringAppointment ID
  final int? id;
  
  /// ID of the customer location for this recurring appointment
  @JsonKey(name: 'customer_location_id')
  final int customerLocationId;
  
  /// Start date of the recurring appointment
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  
  /// Schedule description (e.g., "Every 3 weeks" or "First Monday of the month")
  final String schedule;
  
  /// Team assigned to this recurring appointment
  final String? team;
  
  /// Customer location details
  final CustomerLocation? location;
  
  /// Customer name (for display purposes)
  @JsonKey(name: 'customer_name')
  final String? customerName;
  
  /// Address (for display purposes)
  final String? address;

  /// Constructor
  RecurringAppointment({
    this.id,
    required this.customerLocationId,
    required this.startDate,
    required this.schedule,
    this.team,
    this.location,
    this.customerName,
    this.address,
  });

  /// Create RecurringAppointment from JSON
  factory RecurringAppointment.fromJson(Map<String, dynamic> json) => _$RecurringAppointmentFromJson(json);

  /// Convert RecurringAppointment to JSON
  @override
  Map<String, dynamic> toJson() => _$RecurringAppointmentToJson(this);

  /// Create a copy of RecurringAppointment with updated fields
  @override
  RecurringAppointment copyWith({
    int? id,
    int? customerLocationId,
    DateTime? startDate,
    String? schedule,
    String? team,
    CustomerLocation? location,
    String? customerName,
    String? address,
  }) {
    return RecurringAppointment(
      id: id ?? this.id,
      customerLocationId: customerLocationId ?? this.customerLocationId,
      startDate: startDate ?? this.startDate,
      schedule: schedule ?? this.schedule,
      team: team ?? this.team,
      location: location ?? this.location,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
    );
  }
} 