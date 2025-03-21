import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/appointment.dart';
import '../../core/models/customer.dart';
import '../../core/models/customer_location.dart';
import '../../core/services/customer_service.dart';

class AppointmentForm extends StatefulWidget {
  final Appointment? appointment;
  final Function(Appointment) onSave;
  
  const AppointmentForm({
    super.key,
    this.appointment,
    required this.onSave,
  });

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late int? _customerId;
  late int _customerLocationId;
  late DateTime _arrivalDateTime;
  late DateTime _departureDateTime;
  late String? _team;
  
  List<Customer> _customers = [];
  List<CustomerLocation> _customerLocations = [];
  bool _isLoadingCustomers = false;
  bool _isLoadingLocations = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form values from appointment if editing
    if (widget.appointment != null) {
      _customerLocationId = widget.appointment!.customerLocationId;
      _arrivalDateTime = widget.appointment!.arrivalDateTime;
      _departureDateTime = widget.appointment!.departureDateTime;
      _team = widget.appointment!.team;
      
      // If we have location, we can get customer ID
      if (widget.appointment!.location != null) {
        _customerId = widget.appointment!.location!.customerId;
      }
    } else {
      // Default values for new appointment
      final now = DateTime.now();
      _arrivalDateTime = DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
      _departureDateTime = DateTime(now.year, now.month, now.day, 10, 0); // 10:00 AM
      _team = null;
      _customerId = null;
      _customerLocationId = 0;
    }
    
    // Load customers and locations
    _loadCustomers();
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
  
  Future<void> _selectArrivalDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _arrivalDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_arrivalDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _arrivalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          
          // If departure is before arrival, update it
          if (_departureDateTime.isBefore(_arrivalDateTime)) {
            _departureDateTime = _arrivalDateTime.add(const Duration(hours: 1));
          }
        });
      }
    }
  }
  
  Future<void> _selectDepartureDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureDateTime,
      firstDate: _arrivalDateTime,
      lastDate: _arrivalDateTime.add(const Duration(days: 2)),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _departureDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  
  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      final appointment = Appointment(
        id: widget.appointment?.id,
        customerLocationId: _customerLocationId,
        arrivalDateTime: _arrivalDateTime,
        departureDateTime: _departureDateTime,
        team: _team,
      );
      
      widget.onSave(appointment);
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
          
          // Arrival date and time
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Arrival Date & Time'),
            subtitle: Text(
              DateFormat('EEEE, MMMM d, yyyy - h:mm a').format(_arrivalDateTime),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectArrivalDate,
          ),
          const SizedBox(height: 16),
          
          // Departure date and time
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Departure Date & Time'),
            subtitle: Text(
              DateFormat('EEEE, MMMM d, yyyy - h:mm a').format(_departureDateTime),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDepartureDate,
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
                onPressed: _saveAppointment,
                child: Text(widget.appointment == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 