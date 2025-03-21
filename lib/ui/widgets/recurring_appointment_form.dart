import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/recurring_appointment.dart';
import '../../core/models/customer.dart';
import '../../core/models/customer_location.dart';
import '../../core/services/customer_service.dart';

class RecurringAppointmentForm extends StatefulWidget {
  final RecurringAppointment? recurringAppointment;
  final Function(RecurringAppointment) onSave;
  
  const RecurringAppointmentForm({
    super.key,
    this.recurringAppointment,
    required this.onSave,
  });

  @override
  State<RecurringAppointmentForm> createState() => _RecurringAppointmentFormState();
}

class _RecurringAppointmentFormState extends State<RecurringAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late int? _customerId;
  late int _customerLocationId;
  late DateTime _startDate;
  late String _schedule;
  late String? _team;
  
  List<Customer> _customers = [];
  List<CustomerLocation> _customerLocations = [];
  bool _isLoadingCustomers = false;
  bool _isLoadingLocations = false;
  String? _errorMessage;
  final TextEditingController _scheduleController = TextEditingController();
  
  final List<String> _commonSchedules = [
    'Every Monday at 9 AM',
    'Every other Tuesday at 10 AM',
    'First Wednesday of each month at 1 PM',
    'Every 2 weeks on Thursday at 2 PM',
    'Last Friday of each month at 3 PM',
    'Weekly on Saturday at 11 AM',
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form values from recurring appointment if editing
    if (widget.recurringAppointment != null) {
      _customerLocationId = widget.recurringAppointment!.customerLocationId;
      _startDate = widget.recurringAppointment!.startDate;
      _schedule = widget.recurringAppointment!.schedule;
      _scheduleController.text = _schedule;
      _team = widget.recurringAppointment!.team;
      
      // If we have location, we can get customer ID
      if (widget.recurringAppointment!.location != null) {
        _customerId = widget.recurringAppointment!.location!.customerId;
      }
    } else {
      // Default values for new recurring appointment
      _startDate = DateTime.now();
      _schedule = 'Weekly';
      _scheduleController.text = _schedule;
      _team = null;
      _customerId = null;
      _customerLocationId = 0;
    }
    
    // Load customers and locations
    _loadCustomers();
  }
  
  @override
  void dispose() {
    _scheduleController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
      _errorMessage = null;
    });
    
    try {
      final customerService = Provider.of<CustomerService>(context, listen: false);
      await customerService.getCustomers();
      
      setState(() {
        _customers = customerService.customers;
        _isLoadingCustomers = false;
        
        // Load locations if customer is selected
        if (_customerId != null) {
          _loadCustomerLocations(_customerId!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
        _errorMessage = 'Failed to load customers: ${e.toString()}';
      });
    }
  }
  
  Future<void> _loadCustomerLocations(int customerId) async {
    setState(() {
      _isLoadingLocations = true;
      _errorMessage = null;
    });
    
    try {
      final customerService = Provider.of<CustomerService>(context, listen: false);
      final locations = await customerService.getCustomerLocations(customerId);
      
      setState(() {
        _customerLocations = locations;
        _isLoadingLocations = false;
        
        // If there are locations and none is selected, select the first one
        if (_customerLocations.isNotEmpty && _customerLocationId == 0) {
          _customerLocationId = _customerLocations.first.id ?? 0;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
        _errorMessage = 'Failed to load customer locations: ${e.toString()}';
      });
    }
  }
  
  void _onCustomerChanged(int? customerId) {
    setState(() {
      _customerId = customerId;
      _customerLocationId = 0; // Reset location
      _customerLocations = []; // Clear locations
    });
    
    if (customerId != null) {
      _loadCustomerLocations(customerId);
    }
  }
  
  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }
  
  void _showScheduleSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select a schedule pattern',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...List.generate(_commonSchedules.length, (index) {
            return ListTile(
              title: Text(_commonSchedules[index]),
              onTap: () {
                setState(() {
                  _schedule = _commonSchedules[index];
                  _scheduleController.text = _schedule;
                });
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveRecurringAppointment() {
    if (_formKey.currentState!.validate()) {
      final recurringAppointment = RecurringAppointment(
        id: widget.recurringAppointment?.id,
        customerLocationId: _customerLocationId,
        startDate: _startDate,
        schedule: _schedule,
        team: _team,
      );
      
      widget.onSave(recurringAppointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Customer dropdown
          DropdownButtonFormField<int?>(
            decoration: const InputDecoration(labelText: 'Customer'),
            value: _customerId,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Select a customer'),
              ),
              ..._customers.map((customer) => DropdownMenuItem<int?>(
                value: customer.id,
                child: Text(customer.name),
              )).toList(),
            ],
            onChanged: _isLoadingCustomers ? null : _onCustomerChanged,
            validator: (value) {
              if (value == null) {
                return 'Please select a customer';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Location dropdown
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Location'),
            value: _customerLocationId == 0 ? null : _customerLocationId,
            items: _customerLocations.map((location) => DropdownMenuItem<int>(
              value: location.id ?? 0,
              child: Text(location.address ?? 'No address'),
            )).toList(),
            onChanged: _isLoadingLocations ? null : (value) {
              if (value != null) {
                setState(() {
                  _customerLocationId = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value == 0) {
                return 'Please select a location';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Start date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start Date'),
            subtitle: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_startDate),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectStartDate,
          ),
          const SizedBox(height: 16),
          
          // Schedule pattern
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Schedule Pattern',
              hintText: 'e.g. Every Monday at 9 AM',
              suffixIcon: IconButton(
                icon: const Icon(Icons.list),
                onPressed: _showScheduleSelector,
                tooltip: 'Select from common patterns',
              ),
            ),
            controller: _scheduleController,
            onChanged: (value) {
              _schedule = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a schedule pattern';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Team input
          TextFormField(
            decoration: const InputDecoration(labelText: 'Team (Optional)'),
            initialValue: _team,
            onChanged: (value) {
              setState(() {
                _team = value.isEmpty ? null : value;
              });
            },
          ),
          const SizedBox(height: 24),
          
          // Save button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveRecurringAppointment,
                child: Text(widget.recurringAppointment == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 