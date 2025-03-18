import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Application configuration that uses environment variables instead of .env
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Default values that will be used if environment variables aren't set
  static const String defaultApiUrl = String.fromEnvironment("API_URL", defaultValue: 'http://localhost:8080');
  static const String defaultApiToken = String.fromEnvironment("X_API_TOKEN", defaultValue: '');

  /// Get environment variable or return default value
  String get(String key, {required String defaultValue}) {
    if (kIsWeb) {
      // Web doesn't have access to Platform.environment
      if (key == "API_URL") {
        return defaultApiUrl;
      } else if (key == "X_API_TOKEN") {
        return defaultApiToken;
      }
      return getWebEnv(key, defaultValue);
    } else {
      // Native platforms can access env vars
      return Platform.environment[key] ?? defaultValue;
    }
  }

  /// Get environment variable for web platform
  String getWebEnv(String key, String defaultValue) {
    // In web context, environment variables would be injected
    // into the HTML page, possibly via a global JavaScript object
    // For now, return default values when on web
    return defaultValue;
  }

  /// API URL from environment or default
  String get apiUrl => get('API_URL', defaultValue: defaultApiUrl);

  /// API token from environment or default
  String get apiToken => get('X_API_TOKEN', defaultValue: defaultApiToken);
} 