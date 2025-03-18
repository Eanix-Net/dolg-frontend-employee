import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'service.dart';

part 'invoice_item.g.dart';

/// InvoiceItem model representing a line item on an invoice
@JsonSerializable()
class InvoiceItem implements BaseModel {
  /// InvoiceItem ID
  final int? id;
  
  /// ID of the invoice this item belongs to
  @JsonKey(name: 'invoice_id')
  final int invoiceId;
  
  /// ID of the service provided
  @JsonKey(name: 'service_id')
  final int serviceId;
  
  /// Cost of the service
  final double cost;
  
  /// Service details
  final Service? service;

  /// Constructor
  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.serviceId,
    required this.cost,
    this.service,
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
    int? serviceId,
    double? cost,
    Service? service,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      serviceId: serviceId ?? this.serviceId,
      cost: cost ?? this.cost,
      service: service ?? this.service,
    );
  }
} 