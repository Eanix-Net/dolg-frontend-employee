import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../../core/services/auth_service.dart';
import '../../common/app_drawer.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  static final _logger = Logger('DashboardScreen');

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.hasRole(UserRole.admin);
    final isLead = authService.hasRole(UserRole.lead);
    _logger.info("Made it to the dashboard.");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s an overview of your business',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              
              // Summary cards grid
              GridView.count(
                crossAxisCount: _getColumnCount(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Appointments - All employees
                  SummaryCard(
                    title: 'Appointments',
                    value: '0',
                    icon: Icons.calendar_today_outlined,
                    color: Colors.blue,
                    onTap: () => context.go('/appointments'),
                  ),
                  
                  // Customers - All employees
                  SummaryCard(
                    title: 'Customers',
                    value: '0',
                    icon: Icons.people_outline,
                    color: Colors.orange,
                    onTap: () => context.go('/customers'),
                  ),
                  
                  // Invoices - All employees
                  SummaryCard(
                    title: 'Invoices',
                    value: '0',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.green,
                    onTap: () => context.go('/invoices'),
                  ),
                  
                  // Quotes - All employees
                  SummaryCard(
                    title: 'Quotes',
                    value: '0',
                    icon: Icons.request_quote_outlined,
                    color: Colors.purple,
                    onTap: () => context.go('/quotes'),
                  ),
                  
                  // Equipment - All employees
                  SummaryCard(
                    title: 'Equipment',
                    value: '0',
                    icon: Icons.handyman_outlined,
                    color: Colors.brown,
                    onTap: () => context.go('/equipment'),
                  ),
                  
                  // Timelogs - All employees
                  SummaryCard(
                    title: 'Timelogs',
                    value: '0',
                    icon: Icons.timer_outlined,
                    color: Colors.teal,
                    onTap: () => context.go('/timelogs'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Admin/Lead only section
              if (isLead || isAdmin) ...[
                Text(
                  isAdmin ? 'Admin Tools' : 'Lead Tools',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  crossAxisCount: _getColumnCount(context),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Employees - Lead and Admin only
                    if (isLead)
                      SummaryCard(
                        title: 'Employees',
                        value: '0',
                        icon: Icons.badge_outlined,
                        color: Colors.indigo,
                        onTap: () => context.go('/employees'),
                      ),
                    
                    // Customer Portal - Admin only
                    if (isAdmin)
                      SummaryCard(
                        title: 'Customer Portal',
                        value: 'Manage',
                        icon: Icons.web_outlined,
                        color: Colors.deepOrange,
                        onTap: () => context.go('/customer-portal'),
                      ),
                    
                    // Integrations - Admin only
                    if (isAdmin)
                      SummaryCard(
                        title: 'Integrations',
                        value: 'Configure',
                        icon: Icons.integration_instructions_outlined,
                        color: Colors.blueGrey,
                        onTap: () => context.go('/integrations'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 4;
    } else if (width > 800) {
      return 3;
    } else if (width > 600) {
      return 2;
    } else {
      return 2;
    }
  }
} 