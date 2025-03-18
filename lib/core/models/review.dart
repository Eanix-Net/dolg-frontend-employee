import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'review.g.dart';

/// Review model representing a customer review
@JsonSerializable()
class Review implements BaseModel {
  /// Review ID
  final int? id;
  
  /// ID of the customer who left the review
  @JsonKey(name: 'customer_id')
  final int customerId;
  
  /// ID of the customer location (optional)
  @JsonKey(name: 'location_id')
  final int? locationId;
  
  /// ID of the appointment (optional)
  @JsonKey(name: 'appointment_id')
  final int? appointmentId;
  
  /// Rating (typically 1-5)
  final int rating;
  
  /// Review comment
  final String? comment;
  
  /// Date and time when the review was submitted
  final DateTime? datetime;
  
  /// Customer name (for display purposes)
  @JsonKey(name: 'customer_name')
  final String? customerName;

  /// Constructor
  Review({
    this.id,
    required this.customerId,
    this.locationId,
    this.appointmentId,
    required this.rating,
    this.comment,
    this.datetime,
    this.customerName,
  });

  /// Create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  /// Convert Review to JSON
  @override
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  /// Create a copy of Review with updated fields
  @override
  Review copyWith({
    int? id,
    int? customerId,
    int? locationId,
    int? appointmentId,
    int? rating,
    String? comment,
    DateTime? datetime,
    String? customerName,
  }) {
    return Review(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      locationId: locationId ?? this.locationId,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      datetime: datetime ?? this.datetime,
      customerName: customerName ?? this.customerName,
    );
  }
} 