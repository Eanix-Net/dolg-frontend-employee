import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/recurring_appointment.dart';
import '../../common/app_drawer.dart';
import '../../widgets/appointment_form.dart';
import '../../widgets/recurring_appointment_form.dart';
import 'appointment_details_screen.dart';
import 'recurring_appointment_details_screen.dart';
import '../../widgets/appointment_calendar.dart';
import 'calendar_view.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = false;
  bool _isCreatingAppointment = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  late AppointmentService _appointmentService;
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appointmentService = Provider.of<AppointmentService>(context, listen: false);
      _loadRecurringAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Calculate start and end dates for the current week
      final now = _selectedDate;
      final startDate = now.subtract(Duration(days: now.weekday - 1));
      final endDate = startDate.add(const Duration(days: 6));
      
      await _appointmentService.getAppointments(
        startDate: startDate,
        endDate: endDate,
      );
      
      setState(() {
        _isLoading = false;
        _appointments = _appointmentService.appointments;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  Future<void> _loadRecurringAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _appointmentService.getRecurringAppointments();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  void _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _loadAppointments();
    }
  }
  
  Future<void> _createAppointment() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.hasRole(UserRole.lead)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to create appointments')),
      );
      return;
    }
    
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Appointment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppointmentForm(
                  onSave: (appointment) async {
                    Navigator.pop(context);
                    
                    try {
                      await appointmentService.createAppointment(appointment);
                      
                      // Refresh the appointments list
                      if (mounted) {
                        _loadAppointments();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment created successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _createRecurringAppointment() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.hasRole(UserRole.lead)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to create recurring appointments')),
      );
      return;
    }
    
    final appointmentService = Provider.of<AppointmentService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Recurring Appointment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                RecurringAppointmentForm(
                  onSave: (recurringAppointment) async {
                    Navigator.pop(context);
                    
                    try {
                      await appointmentService.createRecurringAppointment(recurringAppointment);
                      
                      // Refresh the recurring appointments list
                      if (mounted) {
                        _loadRecurringAppointments();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recurring appointment created successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List View'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      drawer: AppDrawer(currentRoute: '/appointments'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(),
          const CalendarView(),
        ],
      ),
      floatingActionButton: authService.hasRole(UserRole.lead)
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Regular Appointment'),
                        onTap: () {
                          Navigator.pop(context);
                          _createAppointment();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.repeat),
                        title: const Text('Recurring Appointment'),
                        onTap: () {
                          Navigator.pop(context);
                          _createRecurringAppointment();
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Appointment'),
              tooltip: 'Create Appointment',
            )
          : null,
    );
  }
  
  Widget _buildListView() {
    return _isLoading && _appointments.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null && _appointments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAppointments,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildDateSelector(),
                  Expanded(
                    child: _buildAppointmentsList(),
                  ),
                ],
              );
  }
  
  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Week of ${_dateFormat.format(_selectedDate)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
  
  Widget _buildAppointmentsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }
  
  Widget _buildRecurringAppointmentsList() {
    final appointmentService = Provider.of<AppointmentService>(context);
    final recurringAppointments = appointmentService.recurringAppointments;
    
    if (recurringAppointments.isEmpty) {
      return const Center(
        child: Text('No recurring appointments'),
      );
    }
    
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recurringAppointments.length,
        itemBuilder: (context, index) {
          final recurringAppointment = recurringAppointments[index];
          // Ensure ID is non-null with a default value of 0 (which should be a valid fallback)
          final appointmentId = recurringAppointment.id ?? 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(recurringAppointment.customerName ?? 'Unknown Customer'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recurringAppointment.address ?? 'No address'),
                  Text('Schedule: ${recurringAppointment.schedule}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecurringAppointmentDetailsScreen(
                      recurringAppointmentId: appointmentId,
                    ),
                  ),
                ).then((_) => _loadAppointments());
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAppointmentCard(Appointment appointment) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to appointment details
          if (appointment.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsScreen(appointmentId: appointment.id!),
              ),
            ).then((_) => _loadAppointments());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.customerName ?? 'Unknown Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (authService.hasRole(UserRole.lead))
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // TODO: Edit appointment
                        } else if (value == 'delete') {
                          // TODO: Delete appointment
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
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
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                appointment.address ?? 'No address',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateFormat.format(appointment.arrivalDateTime)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${timeFormat.format(appointment.arrivalDateTime)} - ${timeFormat.format(appointment.departureDateTime)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (appointment.team != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Team: ${appointment.team}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 