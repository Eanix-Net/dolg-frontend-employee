import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/time_log.dart';

class TimeLogFormDialog extends StatefulWidget {
  final TimeLog? timeLog;
  final int? preselectedAppointmentId;
  final Function(TimeLog) onSave;
  
  const TimeLogFormDialog({
    Key? key,
    this.timeLog,
    this.preselectedAppointmentId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<TimeLogFormDialog> createState() => _TimeLogFormDialogState();
}

class _TimeLogFormDialogState extends State<TimeLogFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _appointmentIdController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _timeInDateController;
  late final TextEditingController _timeInTimeController;
  late final TextEditingController _timeOutDateController;
  late final TextEditingController _timeOutTimeController;
  
  DateTime? _timeIn;
  DateTime? _timeOut;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.timeLog != null;
    
    // Set initial values based on existing time log or defaults
    _timeIn = _isEditMode ? widget.timeLog!.timeIn : DateTime.now();
    _timeOut = _isEditMode ? widget.timeLog!.timeOut : null;
    
    _appointmentIdController = TextEditingController(
      text: _isEditMode 
        ? widget.timeLog!.appointmentId.toString() 
        : widget.preselectedAppointmentId?.toString() ?? ''
    );
    
    _employeeIdController = TextEditingController(
      text: _isEditMode ? widget.timeLog!.employeeId.toString() : ''
    );
    
    _timeInDateController = TextEditingController(
      text: _timeIn != null ? DateFormat('MM/dd/yyyy').format(_timeIn!) : ''
    );
    
    _timeInTimeController = TextEditingController(
      text: _timeIn != null ? DateFormat('hh:mm a').format(_timeIn!) : ''
    );
    
    _timeOutDateController = TextEditingController(
      text: _timeOut != null ? DateFormat('MM/dd/yyyy').format(_timeOut!) : ''
    );
    
    _timeOutTimeController = TextEditingController(
      text: _timeOut != null ? DateFormat('hh:mm a').format(_timeOut!) : ''
    );
  }
  
  @override
  void dispose() {
    _appointmentIdController.dispose();
    _employeeIdController.dispose();
    _timeInDateController.dispose();
    _timeInTimeController.dispose();
    _timeOutDateController.dispose();
    _timeOutTimeController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDateTime(bool isTimeIn) async {
    final initialDate = isTimeIn ? (_timeIn ?? DateTime.now()) : (_timeOut ?? _timeIn ?? DateTime.now());
    
    // Show date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    
    if (pickedDate == null) return;
    
    // Show time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    
    if (pickedTime == null) return;
    
    // Combine date and time
    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    
    setState(() {
      if (isTimeIn) {
        _timeIn = combinedDateTime;
        _timeInDateController.text = DateFormat('MM/dd/yyyy').format(combinedDateTime);
        _timeInTimeController.text = DateFormat('hh:mm a').format(combinedDateTime);
      } else {
        _timeOut = combinedDateTime;
        _timeOutDateController.text = DateFormat('MM/dd/yyyy').format(combinedDateTime);
        _timeOutTimeController.text = DateFormat('hh:mm a').format(combinedDateTime);
      }
    });
  }
  
  // Calculate total time between timeIn and timeOut
  double? _calculateTotalTime() {
    if (_timeIn == null || _timeOut == null) return null;
    
    final difference = _timeOut!.difference(_timeIn!);
    // Convert to hours with 2 decimal places
    return difference.inMinutes / 60.0;
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final int appointmentId = int.parse(_appointmentIdController.text);
      final int employeeId = int.parse(_employeeIdController.text);
      
      if (_timeIn == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select clock-in time')),
        );
        return;
      }
      
      // Calculate total time
      final double? totalTime = _calculateTotalTime();
      
      // Create time log object
      final timeLog = TimeLog(
        id: _isEditMode ? widget.timeLog!.id : null,
        appointmentId: appointmentId,
        employeeId: employeeId,
        timeIn: _timeIn!,
        timeOut: _timeOut,
        totalTime: totalTime,
        employeeName: widget.timeLog?.employeeName,
      );
      
      widget.onSave(timeLog);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Time Log' : 'Add Time Log'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appointment ID
              TextFormField(
                controller: _appointmentIdController,
                decoration: const InputDecoration(
                  labelText: 'Appointment ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter appointment ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Employee ID
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Time In
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeInDateController,
                      decoration: const InputDecoration(
                        labelText: 'Clock In Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _timeInTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Clock In Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Time Out
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeOutDateController,
                      decoration: const InputDecoration(
                        labelText: 'Clock Out Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _timeOutTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Clock Out Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (_timeIn != null && _timeOut != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Time:'),
                      Text(
                        '${_calculateTotalTime()?.toStringAsFixed(2)} hours',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
} 