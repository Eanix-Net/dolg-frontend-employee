import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;
import 'package:logging/logging.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'core/services/auth_service.dart';
import 'core/services/employee_service.dart';
import 'core/api/api_service.dart';
import 'core/config/app_config.dart';
import 'ui/theme/app_theme.dart';
import 'ui/common/app_router.dart';
import 'windows_config.dart';
import 'core/services/equipment_service.dart';
import 'core/services/invoice_service.dart';
import 'core/services/quote_service.dart';
import 'core/services/review_service.dart';
import 'core/services/time_log_service.dart';
import 'core/services/customer_service.dart';
import 'core/services/appointment_service.dart';

void main() async {
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };
  
  // Catch all uncaught errors from the framework
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize logging
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      developer.log(
        '${record.level.name}: ${record.time}: ${record.message}',
        time: record.time,
        name: record.loggerName,
        level: record.level.value,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });
    
    final logger = Logger('main');
    logger.info('Starting application');
    
    // Initialize app config (uses environment variables)
    final appConfig = AppConfig();
    
    // Configure web if running on web platform
    if (kIsWeb) {
      // Web-specific initialization with CORS disabled
      configureWebApp();
      logger.info('Web platform detected, initialized web configuration');
    }
    
    // Initialize Windows configuration only on Windows desktop
    if (!kIsWeb && Platform.isWindows) {
      await WindowsConfig.initialize();
      logger.info('Windows platform detected, initialized windows configuration');
    }
    
    logger.info('Running app');
    runApp(const MyApp());
  }, (error, stack) {
    if (kDebugMode) {
      print('Uncaught error: $error');
      print('Stack trace: $stack');
    }
  });
}

// Web-specific configuration
void configureWebApp() {
  // For web, we need to ensure no CORS headers are added by the app
  // since these are handled by the server
  debugPrint('Running on Web platform - CORS disabled on server side');
  
  // The following JS would typically be injected in the HTML, not here:
  // We can inform the user about CORS configuration
  if (kDebugMode) {
    print('NOTE: For local development, you may need a CORS browser extension if testing against production APIs');
    print('Ensure your backend has CORS properly disabled as configured');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<AppConfig>.value(value: AppConfig()),
        ProxyProvider<AuthService, ApiService>(
          create: (context) => ApiService(context.read<AuthService>()),
          update: (context, authService, previous) => previous ?? ApiService(authService),
        ),
        ChangeNotifierProxyProvider<ApiService, EmployeeService>(
          create: (context) => EmployeeService(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? EmployeeService(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, EquipmentService>(
          create: (context) => EquipmentService(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? EquipmentService(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, InvoiceService>(
          create: (context) => InvoiceService(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? InvoiceService(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, QuoteService>(
          create: (context) => QuoteService(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? QuoteService(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, ReviewService>(
          create: (context) => ReviewService(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? ReviewService(apiService),
        ),
        ProxyProvider2<ApiService, AuthService, TimeLogService>(
          create: (context) => TimeLogService(
            context.read<ApiService>(),
            context.read<AuthService>(),
          ),
          update: (context, apiService, authService, previous) => 
            previous ?? TimeLogService(apiService, authService),
        ),
        ChangeNotifierProxyProvider2<ApiService, AuthService, CustomerService>(
          create: (context) => CustomerService(
            context.read<ApiService>(), 
            context.read<AuthService>()
          ),
          update: (context, apiService, authService, previous) => 
            previous ?? CustomerService(apiService, authService),
        ),
        ChangeNotifierProxyProvider2<ApiService, AuthService, AppointmentService>(
          create: (context) => AppointmentService(
            context.read<ApiService>(), 
            context.read<AuthService>()
          ),
          update: (context, apiService, authService, previous) => 
            previous ?? AppointmentService(apiService, authService),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            title: 'Dolg Employee',
            theme: AppTheme.lightTheme.copyWith(
              // Add desktop-specific theme modifications
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              // Add desktop-specific theme modifications
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router(authService),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Add desktop-specific window controls only on Windows
              return Stack(
                children: [
                  if (child != null) child,
                  if (!kIsWeb && Platform.isWindows)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => WindowsConfig.minimize(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.crop_square),
                            onPressed: () => WindowsConfig.maximize(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => WindowsConfig.close(),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 