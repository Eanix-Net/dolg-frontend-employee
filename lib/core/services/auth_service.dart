import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../config/app_config.dart';

enum UserRole { employee, lead, admin }

class AuthService extends ChangeNotifier {
  static final _logger = Logger('AuthService');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppConfig _config = AppConfig();
  late final String _baseUrl;
  late final String _apiToken;
  
  bool _isAuthenticated = false;
  String? _token;
  UserRole? _userRole;
  int? _userId;
  bool _wasInitialized = false;
  
  AuthService() {
    _baseUrl = _config.get("API_URL", defaultValue: "https://localhost:8080");
    _apiToken = _config.get("X_API_TOKEN", defaultValue: "");
  }
  
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  UserRole? get userRole => _userRole;
  int? get userId => _userId;
  bool get wasInitialized => _wasInitialized;
  
  // Check if user has required role
  bool hasRole(UserRole requiredRole) {
    if (_userRole == null) return false;
    
    switch (requiredRole) {
      case UserRole.employee:
        // All roles can access employee-level features
        return true;
      case UserRole.lead:
        // Only lead and admin can access lead-level features
        return _userRole == UserRole.lead || _userRole == UserRole.admin;
      case UserRole.admin:
        // Only admin can access admin-level features
        return _userRole == UserRole.admin;
      default:
        return false;
    }
  }
  
  // Initialize auth state from storage
  Future<void> init() async {
    _logger.info('Initializing auth service');
    
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      _logger.info('Found stored token');
      final prefs = await SharedPreferences.getInstance();
      final roleStr = prefs.getString('user_role');
      final userId = prefs.getInt('user_id');
      
      _token = token;
      _isAuthenticated = true;
      _userId = userId;
      
      if (roleStr != null) {
        switch (roleStr) {
          case 'admin':
            _userRole = UserRole.admin;
            break;
          case 'lead':
            _userRole = UserRole.lead;
            break;
          case 'employee':
            _userRole = UserRole.employee;
            break;
        }
      }
      
      _logger.info('User authenticated with role: $_userRole, userId: $_userId');
    } else {
      _logger.info('No stored token found, user is not authenticated');
    }
    
    // Mark as initialized regardless of token status
    _wasInitialized = true;
    notifyListeners();
  }
  
  // Login user
  Future<bool> login(String email, String password) async {
    try {
      _logger.info('Attempting login for: $email');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        _logger.info('Login successful, processing token');
        final data = json.decode(response.body);
        final token = data['access_token'];
        
        // Parse JWT to get role
        final parts = token.split('.');
        if (parts.length != 3) {
          _logger.severe('Invalid token format');
          throw Exception('Invalid token format');
        }
        
        // Decode payload
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(decoded);
        
        // Extract user role and ID
        final userRole = payloadMap['user_role'];
        final userId = payloadMap['sub'];
        
        _logger.info('Token decoded - role: $userRole, userId: $userId');
        
        // Save to secure storage
        await _secureStorage.write(key: 'auth_token', value: token);
        
        // Save role and ID to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userRole);
        await prefs.setInt('user_id', userId);
        
        // Update state
        _token = token;
        _isAuthenticated = true;
        _userId = userId;
        _wasInitialized = true;
        
        switch (userRole) {
          case 'admin':
            _userRole = UserRole.admin;
            break;
          case 'lead':
            _userRole = UserRole.lead;
            break;
          case 'employee':
            _userRole = UserRole.employee;
            break;
        }
        
        _logger.info('Authentication state updated, notifying listeners');
        notifyListeners();
        return true;
      }
      
      _logger.warning('Login failed with status code: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.severe('Login error: $e');
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    
    _token = null;
    _isAuthenticated = false;
    _userRole = null;
    _userId = null;
    
    notifyListeners();
  }
} 