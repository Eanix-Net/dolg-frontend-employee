import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../common/app_drawer.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _appointments = [];
  final List<Map<String, dynamic>> _recurringAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement API calls to fetch appointments
    // This would use the ApiService to fetch data from the backend
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data for demonstration
    final sampleAppointments = [
      {
        'id': 1,
        'customer_location_id': 1,
        'customer_name': 'John Smith',
        'address': '123 Main St',
        'arrival_datetime': '2023-04-15T09:00:00',
        'departure_datetime': '2023-04-15T10:30:00',
        'team': 'Team A',
      },
      {
        'id': 2,
        'customer_location_id': 2,
        'customer_name': 'Jane Doe',
        'address': '456 Oak Ave',
        'arrival_datetime': '2023-04-16T13:00:00',
        'departure_datetime': '2023-04-16T14:30:00',
        'team': 'Team B',
      },
    ];
    
    final sampleRecurringAppointments = [
      {
        'id': 1,
        'customer_location_id': 3,
        'customer_name': 'Bob Johnson',
        'address': '789 Pine Rd',
        'start_date': '2023-04-01',
        'schedule': 'Every Monday at 10:00 AM',
        'team': 'Team C',
      },
      {
        'id': 2,
        'customer_location_id': 4,
        'customer_name': 'Alice Williams',
        'address': '321 Cedar Ln',
        'start_date': '2023-04-02',
        'schedule': 'Every other Wednesday at 2:00 PM',
        'team': 'Team A',
      },
    ];

    if (mounted) {
      setState(() {
        _appointments.clear();
        _appointments.addAll(sampleAppointments);
        _recurringAppointments.clear();
        _recurringAppointments.addAll(sampleRecurringAppointments);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final canCreate = authService.hasRole(UserRole.lead);
    final canDelete = authService.hasRole(UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'One-Time'),
            Tab(text: 'Recurring'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/appointments'),
      floatingActionButton: canCreate ? FloatingActionButton(
        onPressed: () {
          _showAddAppointmentDialog(_tabController.index == 1);
        },
        child: const Icon(Icons.add),
      ) : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // One-time appointments tab
          _buildAppointmentsList(canCreate, canDelete),
          
          // Recurring appointments tab
          _buildRecurringAppointmentsList(canCreate, canDelete),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(bool canEdit, bool canDelete) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (canEdit)
              ElevatedButton.icon(
                onPressed: () => _showAddAppointmentDialog(false),
                icon: const Icon(Icons.add),
                label: const Text('Add Appointment'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(appointment['customer_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment['address']),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(appointment['arrival_datetime'])}',
                  ),
                  Text(
                    'Time: ${_formatTime(appointment['arrival_datetime'])} - ${_formatTime(appointment['departure_datetime'])}',
                  ),
                  Text('Team: ${appointment['team']}'),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                    ),
                  if (canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(appointment['id'], false);
                      },
                    ),
                ],
              ),
              onTap: () {
                // TODO: Navigate to appointment details
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecurringAppointmentsList(bool canEdit, bool canDelete) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recurringAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No recurring appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (canEdit)
              ElevatedButton.icon(
                onPressed: () => _showAddAppointmentDialog(true),
                icon: const Icon(Icons.add),
                label: const Text('Add Recurring Appointment'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recurringAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _recurringAppointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(appointment['customer_name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment['address']),
                  const SizedBox(height: 4),
                  Text('Starting: ${appointment['start_date']}'),
                  Text('Schedule: ${appointment['schedule']}'),
                  Text('Team: ${appointment['team']}'),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                    ),
                  if (canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(appointment['id'], true);
                      },
                    ),
                ],
              ),
              onTap: () {
                // TODO: Navigate to recurring appointment details
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddAppointmentDialog(bool isRecurring) {
    // TODO: Implement add appointment dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRecurring ? 'Add Recurring Appointment' : 'Add Appointment'),
        content: const Text('This feature is not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id, bool isRecurring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          isRecurring
              ? 'Are you sure you want to delete this recurring appointment?'
              : 'Are you sure you want to delete this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isRecurring
                        ? 'Recurring appointment deleted'
                        : 'Appointment deleted',
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
} 