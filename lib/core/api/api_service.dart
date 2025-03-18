import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../config/app_config.dart';

// Custom HTTP client with CORS support
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add CORS headers to all requests
    request.headers['Access-Control-Allow-Origin'] = '*';
    request.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    request.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, X-Auth-Token, Authorization';
    // Add a custom Referrer header to override strict-origin-when-cross-origin
    request.headers['Referrer'] = request.url.origin;
    request.headers['Referrer-Policy'] = 'unsafe-url';
    return _inner.send(request);
  }

  Future<http.Response> options(Uri url, {Map<String, String>? headers}) async {
    var request = http.Request('OPTIONS', url);
    if (headers != null) request.headers.addAll(headers);
    // Add CORS headers to OPTIONS requests
    request.headers['Access-Control-Allow-Origin'] = '*';
    request.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    request.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, X-Auth-Token, Authorization';
    request.headers['Referrer'] = url.origin;
    request.headers['Referrer-Policy'] = 'unsafe-url';
    var response = await send(request);
    return http.Response.fromStream(response);
  }

  @override
  void close() {
    _inner.close();
  }
}

class ApiService {
  final AuthService _authService;
  final AppConfig _config = AppConfig();
  late final String _baseUrl;
  late final String _apiToken;
  final CustomHttpClient _client = CustomHttpClient();
  
  ApiService(this._authService) {
    _baseUrl = _config.get("API_URL", defaultValue: "https://localhost:8080");
    _apiToken = _config.get("X_API_TOKEN", defaultValue: "");
  }
  
  // Helper method to get headers with CORS support
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiToken',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token, Authorization',
      'Referrer': _baseUrl,
      'Referrer-Policy': 'unsafe-url',
    };
    
    if (_authService.token != null) {
      headers['X-User-Token'] = _authService.token!;
    }
    
    return headers;
  }

  // Try to perform a preflight OPTIONS request
  Future<bool> checkCorsSupport(String endpoint) async {
    try {
      await _client.options(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: _getHeaders(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('CORS preflight failed: $e');
      }
      return false;
    }
  }
  
  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Generic POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: _getHeaders(),
        body: data != null ? json.encode(data) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: _getHeaders(),
        body: data != null ? json.encode(data) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/api$endpoint'),
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired or invalid, logout user
      _authService.logout();
      throw Exception('Unauthorized');
    } else if (response.statusCode == 403 || response.statusCode == 0) {
      // Could be a CORS issue
      throw Exception('Access denied. This might be a CORS issue.');
    } else {
      final errorMessage = _parseErrorMessage(response);
      throw Exception(errorMessage);
    }
  }
  
  // Parse error message from response
  String _parseErrorMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      return data['msg'] ?? 'Unknown error occurred';
    } catch (e) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }
  
  // Log errors in debug mode
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('API Error: $error');
    }
  }
} 