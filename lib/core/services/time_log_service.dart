import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/time_log.dart';
import 'auth_service.dart';

class TimeLogService {
  final ApiService _apiService;
  final AuthService _authService;
  
  TimeLogService(this._apiService, this._authService);
  
  // Get all time logs
  Future<List<TimeLog>> getTimeLogs() async {
    try {
      final response = await _apiService.get('/time-logs');
      
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeLog.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching time logs: $e');
      }
      rethrow;
    }
  }
  
  // Get time logs for a specific appointment
  Future<List<TimeLog>> getTimeLogsByAppointment(int appointmentId) async {
    try {
      final response = await _apiService.get('/appointments/$appointmentId/time-logs');
      
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeLog.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching time logs by appointment: $e');
      }
      rethrow;
    }
  }
  
  // Get time logs for current employee
  Future<List<TimeLog>> getMyTimeLogs() async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _apiService.get('/employees/$userId/time-logs');
      
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => TimeLog.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching my time logs: $e');
      }
      rethrow;
    }
  }
  
  // Create a new time log (clock in)
  Future<TimeLog> clockIn(int appointmentId) async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final data = {
        'appointment_id': appointmentId,
        'employee_id': userId,
      };
      
      final response = await _apiService.post('/time-logs/clock-in', data: data);
      
      if (response != null && response['data'] != null) {
        return TimeLog.fromJson(response['data']);
      }
      
      throw Exception('Failed to clock in');
    } catch (e) {
      if (kDebugMode) {
        print('Error clocking in: $e');
      }
      rethrow;
    }
  }
  
  // Update a time log (clock out)
  Future<TimeLog> clockOut(int timeLogId) async {
    try {
      final response = await _apiService.post('/time-logs/$timeLogId/clock-out');
      
      if (response != null && response['data'] != null) {
        return TimeLog.fromJson(response['data']);
      }
      
      throw Exception('Failed to clock out');
    } catch (e) {
      if (kDebugMode) {
        print('Error clocking out: $e');
      }
      rethrow;
    }
  }
  
  // Create time log with manual entry
  Future<TimeLog> createTimeLog(TimeLog timeLog) async {
    try {
      final data = timeLog.toJson();
      
      final response = await _apiService.post('/time-logs', data: data);
      
      if (response != null && response['data'] != null) {
        return TimeLog.fromJson(response['data']);
      }
      
      throw Exception('Failed to create time log');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating time log: $e');
      }
      rethrow;
    }
  }
  
  // Update existing time log
  Future<TimeLog> updateTimeLog(TimeLog timeLog) async {
    try {
      if (timeLog.id == null) {
        throw Exception('Time log ID is required for updates');
      }
      
      // Check permissions - only Admin and Lead can edit time logs
      if (!_authService.hasRole(UserRole.lead)) {
        throw Exception('You do not have permission to edit time logs');
      }
      
      final data = timeLog.toJson();
      
      final response = await _apiService.put('/time-logs/${timeLog.id}', data: data);
      
      if (response != null && response['data'] != null) {
        return TimeLog.fromJson(response['data']);
      }
      
      throw Exception('Failed to update time log');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating time log: $e');
      }
      rethrow;
    }
  }
  
  // Delete a time log
  Future<bool> deleteTimeLog(int timeLogId) async {
    try {
      // Check permissions - only Admin can delete time logs
      if (!_authService.hasRole(UserRole.admin)) {
        throw Exception('You do not have permission to delete time logs');
      }
      
      final response = await _apiService.delete('/time-logs/$timeLogId');
      
      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting time log: $e');
      }
      rethrow;
    }
  }
  
  // Check if current user can edit a specific time log
  bool canEditTimeLog(TimeLog timeLog) {
    // Admin can edit anyone's time logs
    if (_authService.hasRole(UserRole.admin)) {
      return true;
    }
    
    // Lead can edit their own and regular employees' time logs
    if (_authService.hasRole(UserRole.lead)) {
      // Get user roles from the backend or use a service to check
      // For now, we can just check if the time log belongs to an admin
      // This would need to be adjusted based on actual backend data
      
      // For demonstration, we'll assume employees with ID < 100 are admins
      // This is a placeholder and should be replaced with actual logic
      if (timeLog.employeeId < 100) {
        return false; // Can't edit admin's time logs
      }
      
      return true;
    }
    
    // Employees can only edit their own time logs if they're still open
    if (_authService.userId == timeLog.employeeId) {
      // Only allow editing if the time log is still open (no time_out yet)
      return timeLog.timeOut == null;
    }
    
    return false;
  }
} 