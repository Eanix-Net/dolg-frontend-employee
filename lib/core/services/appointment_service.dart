import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/appointment.dart';
import '../models/recurring_appointment.dart';
import 'auth_service.dart';

class AppointmentService extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  
  List<Appointment> _appointments = [];
  List<RecurringAppointment> _recurringAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  AppointmentService(this._apiService, this._authService);
  
  List<Appointment> get appointments => _appointments;
  List<RecurringAppointment> get recurringAppointments => _recurringAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Get all appointments
  Future<void> getAppointments({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Build endpoint with date parameters if provided
      String endpoint = '/appointments';
      if (startDate != null || endDate != null) {
        final params = <String>[];
        if (startDate != null) {
          params.add('start_date=${startDate.toIso8601String()}');
        }
        if (endDate != null) {
          params.add('end_date=${endDate.toIso8601String()}');
        }
        if (params.isNotEmpty) {
          endpoint = '$endpoint?${params.join('&')}';
        }
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response != null && response['data'] != null) {
        _appointments = (response['data'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
      } else {
        _appointments = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      if (kDebugMode) {
        print('Error fetching appointments: $e');
      }
      notifyListeners();
      rethrow;
    }
  }
  
  /// Get all recurring appointments
  Future<void> getRecurringAppointments() async {
    try {
      final response = await _apiService.get('/recurring-appointments');
      
      if (response != null && response['data'] != null) {
        _recurringAppointments = (response['data'] as List)
            .map((json) => RecurringAppointment.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recurring appointments: $e');
      }
      rethrow;
    }
  }
  
  /// Get a specific appointment by ID
  Future<Appointment?> getAppointment(int appointmentId) async {
    try {
      final response = await _apiService.get('/appointments/$appointmentId');
      
      if (response != null && response['data'] != null) {
        return Appointment.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Create a new appointment
  Future<Appointment> createAppointment(Appointment appointment) async {
    // Only Admin and Lead can create appointments
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to create appointments');
    }
    
    try {
      final data = appointment.toJson();
      
      final response = await _apiService.post('/appointments', data: data);
      
      if (response != null && response['data'] != null) {
        final newAppointment = Appointment.fromJson(response['data']);
        _appointments.add(newAppointment);
        notifyListeners();
        return newAppointment;
      }
      
      throw Exception('Failed to create appointment');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Create a new recurring appointment
  Future<RecurringAppointment> createRecurringAppointment(RecurringAppointment recurringAppointment) async {
    // Only Admin and Lead can create recurring appointments
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to create recurring appointments');
    }
    
    try {
      final data = recurringAppointment.toJson();
      
      final response = await _apiService.post('/recurring-appointments', data: data);
      
      if (response != null && response['data'] != null) {
        final newRecurringAppointment = RecurringAppointment.fromJson(response['data']);
        _recurringAppointments.add(newRecurringAppointment);
        notifyListeners();
        return newRecurringAppointment;
      }
      
      throw Exception('Failed to create recurring appointment');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating recurring appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Update an existing appointment
  Future<Appointment> updateAppointment(Appointment appointment) async {
    // Only Admin and Lead can update appointments
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to update appointments');
    }
    
    try {
      if (appointment.id == null) {
        throw Exception('Appointment ID is required for updates');
      }
      
      final data = appointment.toJson();
      
      final response = await _apiService.put('/appointments/${appointment.id}', data: data);
      
      if (response != null && response['data'] != null) {
        final updatedAppointment = Appointment.fromJson(response['data']);
        
        // Update the appointment in the list
        final index = _appointments.indexWhere((a) => a.id == appointment.id);
        if (index >= 0) {
          _appointments[index] = updatedAppointment;
          notifyListeners();
        }
        
        return updatedAppointment;
      }
      
      throw Exception('Failed to update appointment');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Update an existing recurring appointment
  Future<RecurringAppointment> updateRecurringAppointment(RecurringAppointment recurringAppointment) async {
    // Only Admin and Lead can update recurring appointments
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to update recurring appointments');
    }
    
    try {
      if (recurringAppointment.id == null) {
        throw Exception('Recurring Appointment ID is required for updates');
      }
      
      final data = recurringAppointment.toJson();
      
      final response = await _apiService.put('/recurring-appointments/${recurringAppointment.id}', data: data);
      
      if (response != null && response['data'] != null) {
        final updatedRecurringAppointment = RecurringAppointment.fromJson(response['data']);
        
        // Update the recurring appointment in the list
        final index = _recurringAppointments.indexWhere((ra) => ra.id == recurringAppointment.id);
        if (index >= 0) {
          _recurringAppointments[index] = updatedRecurringAppointment;
          notifyListeners();
        }
        
        return updatedRecurringAppointment;
      }
      
      throw Exception('Failed to update recurring appointment');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating recurring appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Delete an appointment
  Future<bool> deleteAppointment(int appointmentId) async {
    // Only Admin can delete appointments
    if (!_authService.hasRole(UserRole.admin)) {
      throw Exception('You do not have permission to delete appointments');
    }
    
    try {
      final response = await _apiService.delete('/appointments/$appointmentId');
      
      if (response != null) {
        // Remove the appointment from the list
        _appointments.removeWhere((a) => a.id == appointmentId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting appointment: $e');
      }
      rethrow;
    }
  }
  
  /// Delete a recurring appointment
  Future<bool> deleteRecurringAppointment(int recurringAppointmentId) async {
    // Only Admin can delete recurring appointments
    if (!_authService.hasRole(UserRole.admin)) {
      throw Exception('You do not have permission to delete recurring appointments');
    }
    
    try {
      final response = await _apiService.delete('/recurring-appointments/$recurringAppointmentId');
      
      if (response != null) {
        // Remove the recurring appointment from the list
        _recurringAppointments.removeWhere((ra) => ra.id == recurringAppointmentId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting recurring appointment: $e');
      }
      rethrow;
    }
  }
} 