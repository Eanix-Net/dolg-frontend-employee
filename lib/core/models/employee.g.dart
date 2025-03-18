// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      team: json['team'] as String?,
      role: $enumDecodeNullable(_$EmployeeRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'team': instance.team,
      'role': _$EmployeeRoleEnumMap[instance.role],
    };

const _$EmployeeRoleEnumMap = {
  EmployeeRole.employee: 'employee',
  EmployeeRole.lead: 'lead',
  EmployeeRole.admin: 'admin',
};
