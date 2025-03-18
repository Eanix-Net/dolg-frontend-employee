import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'quote_item.dart';

part 'quote.g.dart';

/// Quote model representing a price quote for a customer
@JsonSerializable()
class Quote implements BaseModel {
  /// Quote ID
  final int? id;
  
  /// ID of the appointment this quote is for
  @JsonKey(name: 'appointment_id')
  final int appointmentId;
  
  /// Estimated total cost
  final double estimate;
  
  /// ID of the employee who created the quote
  @JsonKey(name: 'employee_id')
  final int employeeId;
  
  /// Date when the quote was created
  @JsonKey(name: 'created_date')
  final DateTime? createdDate;
  
  /// Line items on the quote
  final List<QuoteItem>? items;

  /// Constructor
  Quote({
    this.id,
    required this.appointmentId,
    required this.estimate,
    required this.employeeId,
    this.createdDate,
    this.items,
  });

  /// Create Quote from JSON
  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  /// Convert Quote to JSON
  @override
  Map<String, dynamic> toJson() => _$QuoteToJson(this);

  /// Create a copy of Quote with updated fields
  @override
  Quote copyWith({
    int? id,
    int? appointmentId,
    double? estimate,
    int? employeeId,
    DateTime? createdDate,
    List<QuoteItem>? items,
  }) {
    return Quote(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      estimate: estimate ?? this.estimate,
      employeeId: employeeId ?? this.employeeId,
      createdDate: createdDate ?? this.createdDate,
      items: items ?? this.items,
    );
  }
} 