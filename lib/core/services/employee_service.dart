import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/employee.dart';

class EmployeeService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  List<Employee> _employees = [];

  EmployeeService(this._apiService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Employee> get employees => _employees;

  Future<List<Employee>> getEmployees() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/employees');
      _employees = (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
      _setError(null);
      return _employees;
    } catch (e) {
      _setError('Failed to load employees: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Employee?> getEmployee(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/employees/$id');
      final employee = Employee.fromJson(response);
      _setError(null);
      return employee;
    } catch (e) {
      _setError('Failed to load employee: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Employee?> createEmployee(Employee employee) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        '/employees',
        data: employee.toJson(),
      );
      final newEmployee = Employee.fromJson(response);
      _employees.add(newEmployee);
      notifyListeners();
      _setError(null);
      return newEmployee;
    } catch (e) {
      _setError('Failed to create employee: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Employee?> updateEmployee(Employee employee) async {
    _setLoading(true);
    try {
      final response = await _apiService.put(
        '/employees/${employee.id}',
        data: employee.toJson(),
      );
      final updatedEmployee = Employee.fromJson(response);
      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
        notifyListeners();
      }
      _setError(null);
      return updatedEmployee;
    } catch (e) {
      _setError('Failed to update employee: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEmployee(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/employees/$id');
      _employees.removeWhere((e) => e.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete employee: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) {
      notifyListeners();
    }
  }
} 