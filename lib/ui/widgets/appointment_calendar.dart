import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/appointment.dart';
import '../../core/services/appointment_service.dart';
import '../screens/appointments/appointment_details_screen.dart';

class AppointmentCalendar extends StatefulWidget {
  final DateTime initialDate;
  final Function()? onAppointmentCreated;
  
  const AppointmentCalendar({
    super.key,
    required this.initialDate,
    this.onAppointmentCreated,
  });

  @override
  State<AppointmentCalendar> createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  late DateTime _currentWeekStart;
  final DateFormat _dayFormat = DateFormat('EEE\nMMM d');
  final DateFormat _timeFormat = DateFormat('h:mm a');
  final List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
  ];
  
  @override
  void initState() {
    super.initState();
    // Find the start of the week (Monday) for the initial date
    _currentWeekStart = _findWeekStart(widget.initialDate);
  }
  
  DateTime _findWeekStart(DateTime date) {
    // Find Monday of the current week
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }
  
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }
  
  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousWeek,
            tooltip: 'Previous Week',
          ),
          Text(
            'Week of ${DateFormat('MMMM d, yyyy').format(_currentWeekStart)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _nextWeek,
            tooltip: 'Next Week',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarGrid() {
    return Consumer<AppointmentService>(
      builder: (context, appointmentService, child) {
        // Generate list of appointments for the week
        final DateTime weekEnd = _currentWeekStart.add(const Duration(days: 6));
        appointmentService.getAppointments(
          startDate: _currentWeekStart,
          endDate: weekEnd,
        );
        
        final allAppointments = appointmentService.appointments;
        
        return Column(
          children: [
            // Day headers
            _buildDayHeaders(),
            
            // Calendar grid
            Expanded(
              child: SingleChildScrollView(
                child: _buildTimeGrid(allAppointments),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDayHeaders() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // Time column header
          SizedBox(
            width: 80,
            child: Center(
              child: Text(
                'Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          
          // Day headers
          Expanded(
            child: Row(
              children: List.generate(7, (index) {
                final day = _currentWeekStart.add(Duration(days: index));
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                
                return Expanded(
                  child: Container(
                    decoration: isToday
                        ? BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(2),
                    child: Center(
                      child: Text(
                        _dayFormat.format(day),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeGrid(List<Appointment> appointments) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(80),
      },
      border: TableBorder(
        verticalInside: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        horizontalInside: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      children: _timeSlots.map((timeSlot) {
        return _buildTimeRow(timeSlot, appointments);
      }).toList(),
    );
  }
  
  TableRow _buildTimeRow(String timeSlot, List<Appointment> appointments) {
    // Parse the time slot
    final format = DateFormat('h:mm a');
    final time = format.parse(timeSlot);
    
    // Create a reference date with the correct time
    final referenceDate = DateTime(2020, 1, 1, time.hour, time.minute);
    
    return TableRow(
      children: [
        // Time slot
        TableCell(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              timeSlot,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        
        // Days of the week
        ...List.generate(7, (dayIndex) {
          final currentDate = _currentWeekStart.add(Duration(days: dayIndex));
          
          // Find appointments for this day and time slot
          final dayAppointments = appointments.where((appointment) {
            final appointmentDate = appointment.arrivalDateTime;
            final isSameDay = appointmentDate.year == currentDate.year &&
                appointmentDate.month == currentDate.month &&
                appointmentDate.day == currentDate.day;
                
            // Check if appointment overlaps with this time slot
            final appointmentTime = DateTime(
              2020, 1, 1,
              appointmentDate.hour, appointmentDate.minute,
            );
            
            final appointmentEndTime = DateTime(
              2020, 1, 1,
              appointment.departureDateTime.hour, appointment.departureDateTime.minute,
            );
            
            final slotStartTime = referenceDate;
            final slotEndTime = referenceDate.add(const Duration(hours: 1));
            
            return isSameDay && (
              (appointmentTime.isAfter(slotStartTime) && appointmentTime.isBefore(slotEndTime)) ||
              (appointmentEndTime.isAfter(slotStartTime) && appointmentEndTime.isBefore(slotEndTime)) ||
              (appointmentTime.isBefore(slotStartTime) && appointmentEndTime.isAfter(slotEndTime))
            );
          }).toList();
          
          return TableCell(
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(4),
              child: dayAppointments.isEmpty
                  ? const SizedBox()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: dayAppointments.map((appointment) {
                        return Expanded(
                          child: AppointmentCalendarCell(
                            appointment: appointment,
                          ),
                        );
                      }).toList(),
                    ),
            ),
          );
        }),
      ],
    );
  }
}

class AppointmentCalendarCell extends StatelessWidget {
  final Appointment appointment;
  
  const AppointmentCalendarCell({
    super.key,
    required this.appointment,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (appointment.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                appointmentId: appointment.id!,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                appointment.customerName ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (appointment.address != null && appointment.address!.isNotEmpty)
              Flexible(
                child: Text(
                  appointment.address!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 