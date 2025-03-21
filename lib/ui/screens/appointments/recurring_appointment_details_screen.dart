import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/recurring_appointment.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/recurring_appointment_form.dart';

class RecurringAppointmentDetailsScreen extends StatefulWidget {
  final int recurringAppointmentId;
  
  const RecurringAppointmentDetailsScreen({
    super.key,
    required this.recurringAppointmentId,
  });

  @override
  State<RecurringAppointmentDetailsScreen> createState() => _RecurringAppointmentDetailsScreenState();
}

class _RecurringAppointmentDetailsScreenState extends State<RecurringAppointmentDetailsScreen> {
  RecurringAppointment? _recurringAppointment;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadRecurringAppointment();
  }
  
  Future<void> _loadRecurringAppointment() async {
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    
    try {
      // Get all recurring appointments since we don't have a direct method to get one by ID
      await appointmentService.getRecurringAppointments();
      
      // Find the one we're looking for
      final recurringAppointments = appointmentService.recurringAppointments;
      final recurringAppointment = recurringAppointments.firstWhere(
        (ra) => ra.id == widget.recurringAppointmentId,
        orElse: () => throw Exception('Recurring appointment not found'),
      );
      
      setState(() {
        _recurringAppointment = recurringAppointment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load recurring appointment: ${e.toString()}';
      });
    }
  }

  void _showEditDialog() {
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.hasRole(UserRole.lead)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to edit recurring appointments')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: RecurringAppointmentForm(
              recurringAppointment: _recurringAppointment,
              onSave: (updatedRecurringAppointment) async {
                Navigator.pop(context);
                
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  final updated = await appointmentService.updateRecurringAppointment(updatedRecurringAppointment);
                  
                  setState(() {
                    _recurringAppointment = updated;
                    _isLoading = false;
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recurring appointment updated successfully')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Failed to update recurring appointment: ${e.toString()}';
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _confirmDelete() async {
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.hasRole(UserRole.admin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to delete recurring appointments')),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this recurring appointment? '
          'This action cannot be undone and will remove all future occurrences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        final success = await appointmentService.deleteRecurringAppointment(widget.recurringAppointmentId);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recurring appointment deleted successfully')),
            );
            Navigator.pop(context); // Go back to appointments list
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to delete recurring appointment';
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete recurring appointment')),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to delete recurring appointment: ${e.toString()}';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Appointment Details'),
        actions: [
          if (authService.hasRole(UserRole.lead))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isLoading || _recurringAppointment == null ? null : _showEditDialog,
              tooltip: 'Edit Recurring Appointment',
            ),
          if (authService.hasRole(UserRole.admin))
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading || _recurringAppointment == null ? null : _confirmDelete,
              tooltip: 'Delete Recurring Appointment',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecurringAppointment,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_recurringAppointment == null) {
      return const Center(
        child: Text('Recurring appointment not found'),
      );
    }
    
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Text(
                    _recurringAppointment!.customerName ?? 'Unknown Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_recurringAppointment!.address ?? 'No address provided'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Recurring appointment details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recurring Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(dateFormat.format(_recurringAppointment!.startDate)),
                    leading: const Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text('Schedule Pattern'),
                    subtitle: Text(_recurringAppointment!.schedule),
                    leading: const Icon(Icons.repeat),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_recurringAppointment!.team != null)
                    ListTile(
                      title: const Text('Team'),
                      subtitle: Text(_recurringAppointment!.team!),
                      leading: const Icon(Icons.people),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
          
          // Information about upcoming instances
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Instances',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  // TODO: Show upcoming instances when API support is available
                  const ListTile(
                    title: Text('Upcoming instances will be shown here'),
                    subtitle: Text('Check the calendar view to see all scheduled appointments'),
                    leading: Icon(Icons.info_outline),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 