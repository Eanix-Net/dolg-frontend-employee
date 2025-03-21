// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      customerId: (json['customer_id'] as num).toInt(),
      customerName: json['customer_name'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      total: (json['total'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      status: _parseStatusFromJson(json['status'] as String),
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'invoice_number': instance.invoiceNumber,
      'issue_date': instance.issueDate.toIso8601String(),
      'due_date': instance.dueDate.toIso8601String(),
      'total': instance.total,
      'amount_paid': instance.amountPaid,
      'balance': instance.balance,
      'status': _statusToJson(instance.status),
      'notes': instance.notes,
      'items': instance.items,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.declined: 'declined',
};

// Helper functions for InvoiceStatus conversion
InvoiceStatus _parseStatusFromJson(String status) {
  switch (status) {
    case 'draft':
      return InvoiceStatus.draft;
    case 'sent':
      return InvoiceStatus.sent;
    case 'paid':
      return InvoiceStatus.paid;
    case 'overdue':
      return InvoiceStatus.overdue;
    case 'canceled':
      return InvoiceStatus.canceled;
    default:
      return InvoiceStatus.draft;
  }
}

String _statusToJson(InvoiceStatus status) {
  return status.toString().split('.').last;
}
