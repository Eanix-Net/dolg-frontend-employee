import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static final _logger = Logger('SplashScreen');
  bool _isInitializing = true;
  bool _navigationAttempted = false;

  @override
  void initState() {
    super.initState();
    _logger.info('Splash screen initialized');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _logger.info('Starting app initialization');
      
      // Get auth service early
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Important: Check if auth service was already initialized
      // If it was, we should skip this initialization flow to avoid loops
      if (authService.wasInitialized) {
        _logger.info('Auth service already initialized, skipping initialization');
        setState(() {
          _isInitializing = false;
        });
        
        // Let the router handle the navigation
        return;
      }
      
      // Ensure we wait at least 2 seconds for the splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Initialize auth service
      _logger.info('Initializing auth service');
      await authService.init();
      
      // Navigate based on auth state
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
      });
      
      if (authService.isAuthenticated) {
        _logger.info('User authenticated, navigating to dashboard');
        _navigateTo('/dashboard');
      } else {
        _logger.info('User not authenticated, navigating to login');
        _navigateTo('/login');
      }
    } catch (e) {
      _logger.severe('Error during initialization: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        // Default to login on error
        _navigateTo('/login');
      }
    }
  }
  
  void _navigateTo(String route) {
    if (_navigationAttempted) return;
    _navigationAttempted = true;
    
    if (!mounted) return;
    
    // Use a short delay to ensure the state is updated
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _logger.info('Navigating to $route');
        context.go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.grass,
                size: 80,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'Dolg',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            // App subtitle
            Text(
              'Employee Portal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
} 