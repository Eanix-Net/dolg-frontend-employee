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

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  canceled
}

/// Invoice model representing a customer invoice
@JsonSerializable()
class Invoice implements BaseModel {
  /// Invoice ID
  final int? id;
  
  /// Customer ID this invoice is for
  @JsonKey(name: 'customer_id')
  final int customerId;
  
  /// Customer name (for display purposes)
  @JsonKey(name: 'customer_name')
  final String? customerName;
  
  /// Invoice number (for display purposes)
  @JsonKey(name: 'invoice_number')
  final String? invoiceNumber;
  
  /// Date the invoice was issued
  @JsonKey(name: 'issue_date')
  final DateTime issueDate;
  
  /// Due date for payment
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  
  /// Total amount of the invoice
  final double total;
  
  /// Amount that has been paid
  @JsonKey(name: 'amount_paid')
  final double amountPaid;
  
  /// Balance remaining
  final double balance;
  
  /// Current status of the invoice
  final InvoiceStatus status;
  
  /// Notes about the invoice
  final String? notes;
  
  /// Line items on the invoice
  final List<InvoiceItem>? items;
  
  /// Date the invoice was created in the system
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Date the invoice was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Constructor
  Invoice({
    this.id,
    required this.customerId,
    this.customerName,
    this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.total,
    required this.amountPaid,
    required this.balance,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
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
    int? customerId,
    String? customerName,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    double? total,
    double? amountPaid,
    double? balance,
    String? notes,
    List<InvoiceItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static InvoiceStatus _parseStatus(String status) {
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
} 