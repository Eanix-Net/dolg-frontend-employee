import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/models/employee.dart';
import '../../common/app_drawer.dart';
import 'employee_form_dialog.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool _isLoading = true;
  String? _error;
  late EmployeeService _employeeService;

  @override
  void initState() {
    super.initState();
    _employeeService = Provider.of<EmployeeService>(context, listen: false);
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _employeeService.getEmployees();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEmployeeForm({Employee? employee}) async {
    await showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(employee: employee),
    );
  }

  Future<void> _confirmDeleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _employeeService.deleteEmployee(employee.id!);
    }
  }

  Widget _buildEmployeeItem(Employee employee) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final bool canEditEmployees = authService.hasRole(UserRole.admin);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(employee.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.email),
            if (employee.phone != null)
              Text(employee.phone!),
            if (employee.team != null)
              Text('Team: ${employee.team}'),
            Text('Role: ${employee.role?.toString().split('.').last ?? 'employee'}'),
          ],
        ),
        isThreeLine: true,
        trailing: canEditEmployees ? 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEmployeeForm(employee: employee),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _confirmDeleteEmployee(employee),
              ),
            ],
          ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Check if user has lead or admin role
    if (!authService.hasRole(UserRole.lead)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unauthorized'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to access this page',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          if (authService.hasRole(UserRole.admin))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEmployeeForm(),
              tooltip: 'Add Employee',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/employees'),
      body: Consumer<EmployeeService>(
        builder: (context, employeeService, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Employees',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadEmployees,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          final employees = employeeService.employees;
          
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Employees Found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add employees to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (authService.hasRole(UserRole.admin))
                    const SizedBox(height: 16),
                  if (authService.hasRole(UserRole.admin))
                    ElevatedButton.icon(
                      onPressed: () => _showEmployeeForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Employee'),
                    ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) => _buildEmployeeItem(employees[index]),
          );
        },
      ),
    );
  }
} 