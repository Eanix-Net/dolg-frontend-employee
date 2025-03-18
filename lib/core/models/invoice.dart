import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

/// Payment status for invoices
enum PaymentStatus {
  @JsonValue('paid')
  paid,
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('declined')
  declined
}

/// Invoice model representing a customer invoice
@JsonSerializable()
class Invoice implements BaseModel {
  /// Invoice ID
  final int? id;
  
  /// ID of the appointment this invoice is for
  @JsonKey(name: 'appointment_id')
  final int appointmentId;
  
  /// Subtotal amount before tax
  final double subtotal;
  
  /// Total amount including tax
  final double total;
  
  /// Tax rate applied to this invoice
  @JsonKey(name: 'tax_rate')
  final double taxRate;
  
  /// Payment status of the invoice
  final PaymentStatus paid;
  
  /// Number of payment attempts
  final int attempt;
  
  /// Due date for payment
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  
  /// Date when the invoice was created
  @JsonKey(name: 'created_date')
  final DateTime? createdDate;
  
  /// Line items on the invoice
  final List<InvoiceItem>? items;

  /// Constructor
  Invoice({
    this.id,
    required this.appointmentId,
    required this.subtotal,
    required this.total,
    required this.taxRate,
    required this.paid,
    required this.attempt,
    required this.dueDate,
    this.createdDate,
    this.items,
  });

  /// Create Invoice from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  /// Convert Invoice to JSON
  @override
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  /// Create a copy of Invoice with updated fields
  @override
  Invoice copyWith({
    int? id,
    int? appointmentId,
    double? subtotal,
    double? total,
    double? taxRate,
    PaymentStatus? paid,
    int? attempt,
    DateTime? dueDate,
    DateTime? createdDate,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      taxRate: taxRate ?? this.taxRate,
      paid: paid ?? this.paid,
      attempt: attempt ?? this.attempt,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      items: items ?? this.items,
    );
  }
} 