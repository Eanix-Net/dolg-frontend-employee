// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLog _$TimeLogFromJson(Map<String, dynamic> json) => TimeLog(
      id: (json['id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      timeIn: DateTime.parse(json['time_in'] as String),
      timeOut: json['time_out'] == null
          ? null
          : DateTime.parse(json['time_out'] as String),
      totalTime: (json['total_time'] as num?)?.toDouble(),
      employeeName: json['employee_name'] as String?,
    );

Map<String, dynamic> _$TimeLogToJson(TimeLog instance) => <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'employee_id': instance.employeeId,
      'time_in': instance.timeIn.toIso8601String(),
      'time_out': instance.timeOut?.toIso8601String(),
      'total_time': instance.totalTime,
      'employee_name': instance.employeeName,
    };
