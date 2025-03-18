
/// Base class for all models with common functionality
abstract class BaseModel {
  /// Convert model to JSON map
  Map<String, dynamic> toJson();
  
  /// Create a copy of the model with updated fields
  BaseModel copyWith();
} 