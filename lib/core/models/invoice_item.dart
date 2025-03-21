import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'invoice_item.g.dart';

/// InvoiceItem model representing a line item on an invoice
@JsonSerializable()
class InvoiceItem implements BaseModel {
  /// InvoiceItem ID
  final int? id;
  
  /// ID of the invoice this item belongs to
  @JsonKey(name: 'invoice_id')
  final int? invoiceId;
  
  /// Description of the service or product
  final String description;
  
  /// Quantity of the item
  final double quantity;
  
  /// Unit price of the item
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  
  /// Total amount for this line item (quantity * unit_price)
  final double amount;
  
  /// Constructor
  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  /// Create InvoiceItem from JSON
  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);

  /// Convert InvoiceItem to JSON
  @override
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);

  /// Create a copy of InvoiceItem with updated fields
  @override
  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    String? description,
    double? quantity,
    double? unitPrice,
    double? amount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
    );
  }
} 