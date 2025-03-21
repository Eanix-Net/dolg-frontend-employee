import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/customer.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/invoice_service.dart';
import '../../../core/services/customer_service.dart';
import '../../widgets/appointment_form.dart';
import '../../screens/invoices/invoice_details_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;
  
  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  Appointment? _appointment;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }
  
  Future<void> _loadAppointment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      final appointment = await appointmentService.getAppointment(widget.appointmentId);
      
      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load appointment: ${e.toString()}';
      });
    }
  }

  void _showEditDialog() {
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.hasRole(UserRole.lead)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to edit appointments')),
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
            child: AppointmentForm(
              appointment: _appointment,
              onSave: (updatedAppointment) async {
                Navigator.pop(context);
                
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  final updated = await appointmentService.updateAppointment(updatedAppointment);
                  
                  setState(() {
                    _appointment = updated;
                    _isLoading = false;
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment updated successfully')),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Failed to update appointment: ${e.toString()}';
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
        const SnackBar(content: Text('You do not have permission to delete appointments')),
      );
      return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this appointment? This action cannot be undone.'),
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
        
        final success = await appointmentService.deleteAppointment(widget.appointmentId);
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment deleted successfully')),
            );
            Navigator.pop(context); // Go back to appointments list
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to delete appointment';
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete appointment')),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to delete appointment: ${e.toString()}';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _generateInvoice() async {
    if (_appointment == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final invoiceService = Provider.of<InvoiceService>(context, listen: false);
      final customerService = Provider.of<CustomerService>(context, listen: false);
      
      // Get the customer information - assuming we have access to the customer ID
      // through the appointment.location object or customerName
      Customer? customer;
      
      if (_appointment!.location?.customerId != null) {
        // If we have the customer ID directly
        customer = await customerService.getCustomer(_appointment!.location!.customerId!);
      } else {
        // We need to get all customers and find the right one
        await customerService.getCustomers();
        
        // Find the customer by name
        if (_appointment!.customerName != null) {
          final customers = customerService.customers;
          customer = customers.firstWhere(
            (c) => c.name == _appointment!.customerName,
            orElse: () => throw Exception('Could not find customer information for this appointment'),
          );
        } else {
          throw Exception('Could not find customer information for this appointment');
        }
      }
      
      if (customer == null) {
        throw Exception('Could not find customer information for this appointment');
      }
      
      // Generate the invoice
      final invoice = await invoiceService.generateInvoiceFromAppointment(_appointment!, customer);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice generated successfully')),
        );
        
        // Navigate to the invoice details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsScreen(invoiceId: invoice.id!),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate invoice: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _markCompleted() async {
    if (_appointment == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      
      // Update the appointment status (assuming there's a status field in the model)
      // Since the Appointment doesn't have a status field yet, you would need to add it
      // This is a placeholder for when that field is added
      // final updatedAppointment = _appointment!.copyWith(status: AppointmentStatus.completed);
      // await appointmentService.updateAppointment(updatedAppointment);
      
      // For now, just reload the appointment
      await _loadAppointment();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment marked as completed')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to mark appointment as completed: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          if (authService.hasRole(UserRole.lead) && _appointment != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog();
                } else if (value == 'delete') {
                  _confirmDelete();
                } else if (value == 'complete') {
                  _markCompleted();
                } else if (value == 'invoice') {
                  _generateInvoice();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Appointment'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text('Mark as Completed'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'invoice',
                  child: Row(
                    children: [
                      Icon(Icons.receipt),
                      SizedBox(width: 8),
                      Text('Generate Invoice'),
                    ],
                  ),
                ),
                if (authService.hasRole(UserRole.admin))
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Appointment', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
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
              onPressed: _loadAppointment,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_appointment == null) {
      return const Center(
        child: Text('Appointment not found'),
      );
    }
    
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
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
                    _appointment!.customerName ?? 'Unknown Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_appointment!.address ?? 'No address provided'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Appointment details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(dateFormat.format(_appointment!.arrivalDateTime)),
                    leading: const Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(
                      '${timeFormat.format(_appointment!.arrivalDateTime)} - ${timeFormat.format(_appointment!.departureDateTime)}'
                    ),
                    leading: const Icon(Icons.access_time),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_appointment!.team != null)
                    ListTile(
                      title: const Text('Team'),
                      subtitle: Text(_appointment!.team!),
                      leading: const Icon(Icons.people),
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