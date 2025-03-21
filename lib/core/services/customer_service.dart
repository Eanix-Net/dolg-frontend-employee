import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/customer.dart';
import '../models/customer_location.dart';
import 'auth_service.dart';

class CustomerService extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  CustomerService(this._apiService, this._authService);
  
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Get all customers
  Future<void> getCustomers() async {
    // Only Admin and Lead can view all customers
    if (!_authService.hasRole(UserRole.lead)) {
      _errorMessage = 'You do not have permission to view all customers';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/customers');
      
      if (response != null && response['data'] != null) {
        _customers = (response['data'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();
      } else {
        _customers = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load customers: ${e.toString()}';
      if (kDebugMode) {
        print('Error fetching customers: $e');
      }
      notifyListeners();
      rethrow;
    }
  }
  
  /// Get a specific customer by ID
  Future<Customer?> getCustomer(int customerId) async {
    try {
      final response = await _apiService.get('/customers/$customerId');
      
      if (response != null && response['data'] != null) {
        return Customer.fromJson(response['data']);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer: $e');
      }
      rethrow;
    }
  }
  
  /// Create a new customer
  Future<Customer> createCustomer(Customer customer) async {
    // Only Admin and Lead can create customers
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to create customers');
    }
    
    try {
      final data = customer.toJson();
      
      final response = await _apiService.post('/customers', data: data);
      
      if (response != null && response['data'] != null) {
        final newCustomer = Customer.fromJson(response['data']);
        _customers.add(newCustomer);
        notifyListeners();
        return newCustomer;
      }
      
      throw Exception('Failed to create customer');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating customer: $e');
      }
      rethrow;
    }
  }
  
  /// Update an existing customer
  Future<Customer> updateCustomer(Customer customer) async {
    // Only Admin and Lead can update customers
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to update customers');
    }
    
    try {
      if (customer.id == null) {
        throw Exception('Customer ID is required for updates');
      }
      
      final data = customer.toJson();
      
      final response = await _apiService.put('/customers/${customer.id}', data: data);
      
      if (response != null && response['data'] != null) {
        final updatedCustomer = Customer.fromJson(response['data']);
        
        // Update the customer in the list
        final index = _customers.indexWhere((c) => c.id == customer.id);
        if (index >= 0) {
          _customers[index] = updatedCustomer;
          notifyListeners();
        }
        
        return updatedCustomer;
      }
      
      throw Exception('Failed to update customer');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating customer: $e');
      }
      rethrow;
    }
  }
  
  /// Delete a customer
  Future<bool> deleteCustomer(int customerId) async {
    // Only Admin can delete customers
    if (!_authService.hasRole(UserRole.admin)) {
      throw Exception('You do not have permission to delete customers');
    }
    
    try {
      final response = await _apiService.delete('/customers/$customerId');
      
      if (response != null) {
        // Remove the customer from the list
        _customers.removeWhere((c) => c.id == customerId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting customer: $e');
      }
      rethrow;
    }
  }
  
  /// Get all locations for a customer
  Future<List<CustomerLocation>> getCustomerLocations(int customerId) async {
    try {
      final response = await _apiService.get('/customers/$customerId/locations');
      
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => CustomerLocation.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer locations: $e');
      }
      rethrow;
    }
  }
  
  /// Create a new customer location
  Future<CustomerLocation> createCustomerLocation(CustomerLocation location) async {
    // Only Admin and Lead can create customer locations
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to create customer locations');
    }
    
    try {
      final data = location.toJson();
      
      final response = await _apiService.post('/customer-locations', data: data);
      
      if (response != null && response['data'] != null) {
        return CustomerLocation.fromJson(response['data']);
      }
      
      throw Exception('Failed to create customer location');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating customer location: $e');
      }
      rethrow;
    }
  }
  
  /// Update an existing customer location
  Future<CustomerLocation> updateCustomerLocation(CustomerLocation location) async {
    // Only Admin and Lead can update customer locations
    if (!_authService.hasRole(UserRole.lead)) {
      throw Exception('You do not have permission to update customer locations');
    }
    
    try {
      if (location.id == null) {
        throw Exception('Location ID is required for updates');
      }
      
      final data = location.toJson();
      
      final response = await _apiService.put('/customer-locations/${location.id}', data: data);
      
      if (response != null && response['data'] != null) {
        return CustomerLocation.fromJson(response['data']);
      }
      
      throw Exception('Failed to update customer location');
    } catch (e) {
      if (kDebugMode) {
        print('Error updating customer location: $e');
      }
      rethrow;
    }
  }
  
  /// Delete a customer location
  Future<bool> deleteCustomerLocation(int locationId) async {
    // Only Admin can delete customer locations
    if (!_authService.hasRole(UserRole.admin)) {
      throw Exception('You do not have permission to delete customer locations');
    }
    
    try {
      final response = await _apiService.delete('/customer-locations/$locationId');
      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting customer location: $e');
      }
      rethrow;
    }
  }
  
  /// Search customers by name or email
  Future<List<Customer>> searchCustomers(String query) async {
    if (query.isEmpty) {
      return _customers;
    }
    
    try {
      final response = await _apiService.get('/customers/search?q=${Uri.encodeComponent(query)}');
      
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error searching customers: $e');
      }
      rethrow;
    }
  }
} 