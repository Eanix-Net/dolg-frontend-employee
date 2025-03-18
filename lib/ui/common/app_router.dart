import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../core/services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/employees/employees_screen.dart';
import '../screens/equipment/equipment_screen.dart';
import '../screens/invoices/invoices_screen.dart';
import '../screens/locations/locations_screen.dart';
import '../screens/photos/photos_screen.dart';
import '../screens/quotes/quotes_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/timelogs/timelogs_screen.dart';
import '../screens/customer_portal/customer_portal_screen.dart';
import '../screens/integrations/integrations_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/not_found_screen.dart';

class AppRouter {
  static final _logger = Logger('AppRouter');
  
  static GoRouter router(AuthService authService) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authService,
      debugLogDiagnostics: kDebugMode,
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = authService.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        final isSplashRoute = state.matchedLocation == '/';
        final isDashboardRoute = state.matchedLocation == '/dashboard';
        
        _logger.info('Redirect check - path: ${state.matchedLocation}, isLoggedIn: $isLoggedIn, authToken: ${authService.token != null}');
        
        // Allow splash screen to handle its own redirects ONLY on initial app load
        // This is the key fix - we should only allow the splash screen to handle navigation
        // on initial app load, not when coming back to it from other routes
        if (isSplashRoute && !authService.wasInitialized) {
          _logger.info('On splash route during initial load, allowing splash screen to handle redirection');
          return null;
        }
        
        // If on splash screen but auth service was already initialized, redirect appropriately
        if (isSplashRoute && authService.wasInitialized) {
          _logger.info('On splash route after initialization, redirecting based on auth state');
          if (isLoggedIn) {
            return '/dashboard';
          } else {
            return '/login';
          }
        }
        
        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && !isLoginRoute) {
          _logger.info('Not logged in and not on login page, redirecting to login');
          return '/login';
        }
        
        // If logged in and on login page, redirect to dashboard
        if (isLoggedIn && isLoginRoute) {
          _logger.info('Logged in and on login page, redirecting to dashboard');
          return '/dashboard';
        }
        
        // If we're logged in but trying to access a non-existing route, go to dashboard
        if (isLoggedIn && state.error != null) {
          _logger.info('Route error while logged in, redirecting to dashboard');
          return '/dashboard';
        }
        
        // No redirect needed
        _logger.info('No redirect needed for ${state.matchedLocation}');
        return null;
      },
      errorBuilder: (context, state) {
        _logger.warning('Navigation error: ${state.error}');
        return const NotFoundScreen();
      },
      routes: [
        // Splash screen
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        // Main app routes
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        
        // Appointments
        GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsScreen(),
        ),
        
        // Customers
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersScreen(),
        ),
        
        // Employees
        GoRoute(
          path: '/employees',
          builder: (context, state) => const EmployeesScreen(),
        ),
        
        // Equipment
        GoRoute(
          path: '/equipment',
          builder: (context, state) => const EquipmentScreen(),
        ),
        
        // Invoices
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoicesScreen(),
        ),
        
        // Locations
        GoRoute(
          path: '/locations',
          builder: (context, state) => const LocationsScreen(),
        ),
        
        // Photos
        GoRoute(
          path: '/photos',
          builder: (context, state) => const PhotosScreen(),
        ),
        
        // Quotes
        GoRoute(
          path: '/quotes',
          builder: (context, state) => const QuotesScreen(),
        ),
        
        // Reviews
        GoRoute(
          path: '/reviews',
          builder: (context, state) => const ReviewsScreen(),
        ),
        
        // Timelogs
        GoRoute(
          path: '/timelogs',
          builder: (context, state) => const TimelogsScreen(),
        ),
        
        // Customer Portal
        GoRoute(
          path: '/customer-portal',
          builder: (context, state) => const CustomerPortalScreen(),
        ),
        
        // Integrations
        GoRoute(
          path: '/integrations',
          builder: (context, state) => const IntegrationsScreen(),
        ),
      ],
    );
  }
} 