import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'service.dart';

part 'quote_item.g.dart';

/// QuoteItem model representing a line item on a quote
@JsonSerializable()
class QuoteItem implements BaseModel {
  /// QuoteItem ID
  final int? id;
  
  /// ID of the quote this item belongs to
  @JsonKey(name: 'quote_id')
  final int quoteId;
  
  /// ID of the service provided
  @JsonKey(name: 'service_id')
  final int serviceId;
  
  /// Cost of the service
  final double cost;
  
  /// Service details
  final Service? service;

  /// Constructor
  QuoteItem({
    this.id,
    required this.quoteId,
    required this.serviceId,
    required this.cost,
    this.service,
  });

  /// Create QuoteItem from JSON
  factory QuoteItem.fromJson(Map<String, dynamic> json) => _$QuoteItemFromJson(json);

  /// Convert QuoteItem to JSON
  @override
  Map<String, dynamic> toJson() => _$QuoteItemToJson(this);

  /// Create a copy of QuoteItem with updated fields
  @override
  QuoteItem copyWith({
    int? id,
    int? quoteId,
    int? serviceId,
    double? cost,
    Service? service,
  }) {
    return QuoteItem(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      serviceId: serviceId ?? this.serviceId,
      cost: cost ?? this.cost,
      service: service ?? this.service,
    );
  }
} 