// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      invoiceId: (json['invoice_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMethod: _parsePaymentMethodFromJson(json['payment_method'] as String),
      status: json['status'] == null
          ? PaymentStatus.completed
          : _parsePaymentStatusFromJson(json['status'] as String),
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'amount': instance.amount,
      'payment_date': instance.paymentDate.toIso8601String(),
      'payment_method': _paymentMethodToJson(instance.paymentMethod),
      'status': _paymentStatusToJson(instance.status),
      'reference_number': instance.referenceNumber,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

// Helper functions for PaymentMethod conversion
PaymentMethod _parsePaymentMethodFromJson(String method) {
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

String _paymentMethodToJson(PaymentMethod method) {
  return method.toString().split('.').last;
}

// Helper functions for PaymentStatus conversion
PaymentStatus _parsePaymentStatusFromJson(String status) {
  switch (status) {
    case 'pending':
      return PaymentStatus.pending;
    case 'completed':
      return PaymentStatus.completed;
    case 'failed':
      return PaymentStatus.failed;
    case 'refunded':
      return PaymentStatus.refunded;
    default:
      return PaymentStatus.completed;
  }
}

String _paymentStatusToJson(PaymentStatus status) {
  return status.toString().split('.').last;
} 