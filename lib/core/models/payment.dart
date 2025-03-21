import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'payment.g.dart';

enum PaymentMethod {
  cash,
  check,
  creditCard,
  debit,
  bankTransfer,
  other
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded
}

/// Payment model representing a payment made against an invoice
@JsonSerializable()
class Payment implements BaseModel {
  /// Payment ID
  final int? id;
  
  /// ID of the invoice this payment is for
  @JsonKey(name: 'invoice_id')
  final int invoiceId;
  
  /// Amount of the payment
  final double amount;
  
  /// Date the payment was made
  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;
  
  /// Payment method used
  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;
  
  /// Status of the payment
  final PaymentStatus status;
  
  /// Reference number for the payment (e.g., check number, transaction ID)
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  
  /// Notes about the payment
  final String? notes;
  
  /// Date the payment was created in the system
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Date the payment was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Constructor
  Payment({
    this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.status = PaymentStatus.completed,
    this.referenceNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Payment from JSON
  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  /// Convert Payment to JSON
  @override
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  /// Create a copy of Payment with updated fields
  @override
  Payment copyWith({
    int? id,
    int? invoiceId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? referenceNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return PaymentMethod.cash;
      case 'check':
        return PaymentMethod.check;
      case 'credit_card':
      case 'creditCard':
        return PaymentMethod.creditCard;
      case 'debit':
        return PaymentMethod.debit;
      case 'bank_transfer':
      case 'bankTransfer':
        return PaymentMethod.bankTransfer;
      case 'other':
      default:
        return PaymentMethod.other;
    }
  }
} 