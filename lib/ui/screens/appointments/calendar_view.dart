import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/appointment.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/auth_service.dart';
import 'appointment_details_screen.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late Map<DateTime, List<Appointment>> _events;
  List<Appointment> _selectedEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _events = {};
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final appointmentService = Provider.of<AppointmentService>(context, listen: false);
      await appointmentService.getAppointments();
      
      final events = <DateTime, List<Appointment>>{};
      
      for (final appointment in appointmentService.appointments) {
        final date = DateTime(
          appointment.arrivalDateTime.year,
          appointment.arrivalDateTime.month,
          appointment.arrivalDateTime.day,
        );
        
        if (events[date] == null) {
          events[date] = [];
        }
        
        events[date]!.add(appointment);
      }
      
      setState(() {
        _events = events;
        _isLoading = false;
        _getEventsForDay(_selectedDay);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  List<Appointment> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    _selectedEvents = _events[normalizedDay] ?? [];
    return _selectedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _events.isEmpty
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
                    TableCalendar<Appointment>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      eventLoader: _getEventsForDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _getEventsForDay(selectedDay);
                          });
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: const CalendarStyle(
                        // Customize calendar style here
                        todayDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Text(
                                  '${events.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildEventsList(),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildEventsList() {
    return ListView.builder(
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final appointment = _selectedEvents[index];
        final timeFormat = DateFormat('h:mm a');
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(appointment.customerName ?? 'No Customer Name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.address ?? 'No Address'),
                Text(
                  '${timeFormat.format(appointment.arrivalDateTime)} - ${timeFormat.format(appointment.departureDateTime)}',
                ),
              ],
            ),
            trailing: appointment.team != null 
                ? Chip(label: Text(appointment.team!))
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(appointmentId: appointment.id!),
                ),
              ).then((_) => _loadAppointments());
            },
          ),
        );
      },
    );
  }
} 