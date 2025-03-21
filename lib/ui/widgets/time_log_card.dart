import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/time_log.dart';
import '../../core/services/auth_service.dart';

class TimeLogCard extends StatelessWidget {
  final TimeLog timeLog;
  final AuthService authService;
  final Function() onEdit;
  final Function() onDelete;
  final Function()? onClockOut;
  
  const TimeLogCard({
    Key? key,
    required this.timeLog,
    required this.authService,
    required this.onEdit,
    required this.onDelete,
    this.onClockOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    final bool isActive = timeLog.timeOut == null;
    final bool canEdit = authService.hasRole(UserRole.lead) || 
        (authService.userId == timeLog.employeeId && isActive);
    
    // Check specific role-based permissions
    final bool isAdmin = authService.hasRole(UserRole.admin);
    final bool isLead = authService.hasRole(UserRole.lead) && !isAdmin;
    final bool canEditThisLog = _canEditTimeLog(timeLog);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isActive ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    timeLog.employeeName ?? 'Employee ${timeLog.employeeId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Appointment #${timeLog.appointmentId}',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clock In',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${dateFormat.format(timeLog.timeIn)} at ${timeFormat.format(timeLog.timeIn)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Clock Out',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    timeLog.timeOut != null
                        ? Text(
                            '${dateFormat.format(timeLog.timeOut!)} at ${timeFormat.format(timeLog.timeOut!)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        : const Text(
                            'Not clocked out yet',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ],
            ),
            if (timeLog.totalTime != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total Time: ${timeLog.totalTime!.toStringAsFixed(2)} hours',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Only show clock out button if the time log is active and it belongs to the current user
                if (isActive && authService.userId == timeLog.employeeId && onClockOut != null)
                  ElevatedButton.icon(
                    onPressed: onClockOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Clock Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                // Spacer
                if ((isActive && authService.userId == timeLog.employeeId && onClockOut != null) && 
                    canEditThisLog)
                  const SizedBox(width: 8),
                  
                // Edit button - shown only if user has permissions to edit this log
                if (canEditThisLog)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                
                // Delete button - shown only for admins
                if (isAdmin)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Implementation of role-based permission logic
  bool _canEditTimeLog(TimeLog timeLog) {
    // Admin can edit anyone's time logs
    if (authService.hasRole(UserRole.admin)) {
      return true;
    }
    
    // Lead can edit their own and regular employees' time logs
    if (authService.hasRole(UserRole.lead)) {
      // For demonstration, we'll assume employees with ID < 100 are admins
      // This is a placeholder and should be replaced with actual logic
      if (timeLog.employeeId < 100) {
        return false; // Lead can't edit admin's time logs
      }
      
      return true;
    }
    
    // Employees can only edit their own time logs if they're still open
    if (authService.userId == timeLog.employeeId) {
      // Only allow editing if the time log is still open (no time_out yet)
      return timeLog.timeOut == null;
    }
    
    return false;
  }
} 