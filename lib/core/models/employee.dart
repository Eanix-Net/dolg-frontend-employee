import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'employee.g.dart';

/// Employee roles in the system
enum EmployeeRole {
  @JsonValue('employee')
  employee,
  @JsonValue('lead')
  lead,
  @JsonValue('admin')
  admin
}

/// Employee model representing an employee in the system
@JsonSerializable()
class Employee implements BaseModel {
  /// Employee ID
  final int? id;
  
  /// Employee name
  final String name;
  
  /// Employee phone number
  final String? phone;
  
  /// Employee email address
  final String email;
  
  /// Employee team assignment
  final String? team;
  
  /// Employee role (employee, lead, admin)
  final EmployeeRole? role;

  /// Constructor
  Employee({
    this.id,
    required this.name,
    this.phone,
    required this.email,
    this.team,
    this.role,
  });

  /// Create Employee from JSON
  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

  /// Convert Employee to JSON
  @override
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  /// Create a copy of Employee with updated fields
  @override
  Employee copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? team,
    EmployeeRole? role,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      team: team ?? this.team,
      role: role ?? this.role,
    );
  }
} 