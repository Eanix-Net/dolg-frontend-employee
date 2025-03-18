import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'photo.g.dart';

/// Photo model representing a job site photo
@JsonSerializable()
class Photo implements BaseModel {
  /// Photo ID
  final int? id;
  
  /// ID of the appointment this photo is for
  @JsonKey(name: 'appointment_id')
  final int appointmentId;
  
  /// File path or URL to the photo
  @JsonKey(name: 'file_path')
  final String filePath;
  
  /// Who uploaded the photo
  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;
  
  /// Who approved the photo
  @JsonKey(name: 'approved_by')
  final String? approvedBy;
  
  /// Whether to show the photo to the customer
  @JsonKey(name: 'show_to_customer')
  final bool? showToCustomer;
  
  /// Whether to show the photo on the website
  @JsonKey(name: 'show_on_website')
  final bool? showOnWebsite;
  
  /// Date and time when the photo was uploaded
  final DateTime? datetime;

  /// Constructor
  Photo({
    this.id,
    required this.appointmentId,
    required this.filePath,
    this.uploadedBy,
    this.approvedBy,
    this.showToCustomer,
    this.showOnWebsite,
    this.datetime,
  });

  /// Create Photo from JSON
  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  /// Convert Photo to JSON
  @override
  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  /// Create a copy of Photo with updated fields
  @override
  Photo copyWith({
    int? id,
    int? appointmentId,
    String? filePath,
    String? uploadedBy,
    String? approvedBy,
    bool? showToCustomer,
    bool? showOnWebsite,
    DateTime? datetime,
  }) {
    return Photo(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      filePath: filePath ?? this.filePath,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      showToCustomer: showToCustomer ?? this.showToCustomer,
      showOnWebsite: showOnWebsite ?? this.showOnWebsite,
      datetime: datetime ?? this.datetime,
    );
  }
} 