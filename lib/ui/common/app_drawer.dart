import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.hasRole(UserRole.admin);
    final isLead = authService.hasRole(UserRole.lead);

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          UserAccountsDrawerHeader(
            accountName: const Text('Employee'),
            accountEmail: Text('ID: ${authService.userId ?? "Unknown"}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),
                
                // Appointments - All employees
                _buildNavItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Appointments',
                  route: '/appointments',
                ),
                
                // Customers - All employees
                _buildNavItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'Customers',
                  route: '/customers',
                ),
                
                // Employees - Lead and Admin only
                if (isLead)
                  _buildNavItem(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'Employees',
                    route: '/employees',
                  ),
                
                // Equipment - All employees
                _buildNavItem(
                  context,
                  icon: Icons.handyman_outlined,
                  title: 'Equipment',
                  route: '/equipment',
                ),
                
                // Invoices - All employees
                _buildNavItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Invoices',
                  route: '/invoices',
                ),
                
                // Locations - All employees
                _buildNavItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Locations',
                  route: '/locations',
                ),
                
                // Photos - All employees
                _buildNavItem(
                  context,
                  icon: Icons.photo_library_outlined,
                  title: 'Photos',
                  route: '/photos',
                ),
                
                // Quotes - All employees
                _buildNavItem(
                  context,
                  icon: Icons.request_quote_outlined,
                  title: 'Quotes',
                  route: '/quotes',
                ),
                
                // Reviews - All employees
                _buildNavItem(
                  context,
                  icon: Icons.star_outline,
                  title: 'Reviews',
                  route: '/reviews',
                ),
                
                // Timelogs - All employees
                _buildNavItem(
                  context,
                  icon: Icons.timer_outlined,
                  title: 'Timelogs',
                  route: '/timelogs',
                ),
                
                // Customer Portal - Admin only
                if (isAdmin)
                  _buildNavItem(
                    context,
                    icon: Icons.web_outlined,
                    title: 'Customer Portal',
                    route: '/customer-portal',
                  ),
                
                // Integrations - Admin only
                if (isAdmin)
                  _buildNavItem(
                    context,
                    icon: Icons.integration_instructions_outlined,
                    title: 'Integrations',
                    route: '/integrations',
                  ),
                
                const Divider(),
                
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await authService.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = currentRoute == route;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
        Navigator.pop(context); // Close drawer
      },
    );
  }
} 