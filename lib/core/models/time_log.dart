import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'time_log.g.dart';

/// TimeLog model representing an employee's time tracking for a job
@JsonSerializable()
class TimeLog implements BaseModel {
  /// TimeLog ID
  final int? id;
  
  /// ID of the appointment this time log is for
  @JsonKey(name: 'appointment_id')
  final int appointmentId;
  
  /// ID of the employee who worked
  @JsonKey(name: 'employee_id')
  final int employeeId;
  
  /// Time when the employee clocked in
  @JsonKey(name: 'time_in')
  final DateTime timeIn;
  
  /// Time when the employee clocked out
  @JsonKey(name: 'time_out')
  final DateTime? timeOut;
  
  /// Total time worked in hours
  @JsonKey(name: 'total_time')
  final double? totalTime;
  
  /// Employee name (for display purposes)
  @JsonKey(name: 'employee_name')
  final String? employeeName;

  /// Constructor
  TimeLog({
    this.id,
    required this.appointmentId,
    required this.employeeId,
    required this.timeIn,
    this.timeOut,
    this.totalTime,
    this.employeeName,
  });

  /// Create TimeLog from JSON
  factory TimeLog.fromJson(Map<String, dynamic> json) => _$TimeLogFromJson(json);

  /// Convert TimeLog to JSON
  @override
  Map<String, dynamic> toJson() => _$TimeLogToJson(this);

  /// Create a copy of TimeLog with updated fields
  @override
  TimeLog copyWith({
    int? id,
    int? appointmentId,
    int? employeeId,
    DateTime? timeIn,
    DateTime? timeOut,
    double? totalTime,
    String? employeeName,
  }) {
    return TimeLog(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      employeeId: employeeId ?? this.employeeId,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      totalTime: totalTime ?? this.totalTime,
      employeeName: employeeName ?? this.employeeName,
    );
  }
} 