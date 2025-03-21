import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/time_log.dart';
import '../../../core/services/auth_service.dart';
import '../../common/app_drawer.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_display.dart';
import '../../../core/services/time_log_service.dart';
import '../../widgets/time_log_card.dart';
import '../../widgets/time_log_form_dialog.dart';

class TimelogsScreen extends StatefulWidget {
  const TimelogsScreen({super.key});

  @override
  State<TimelogsScreen> createState() => _TimelogsScreenState();
}

class _TimelogsScreenState extends State<TimelogsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TimeLog>? _allTimeLogs;
  List<TimeLog>? _myTimeLogs;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTimeLogs();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTimeLogs() async {
    final timeLogService = Provider.of<TimeLogService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Load all time logs (for admin/lead) and my time logs (for everyone)
      final myTimeLogs = await timeLogService.getMyTimeLogs();
      
      if (authService.hasRole(UserRole.lead)) {
        // Admins and leads can see all time logs
        final allTimeLogs = await timeLogService.getTimeLogs();
        
        setState(() {
          _allTimeLogs = allTimeLogs;
          _myTimeLogs = myTimeLogs;
          _isLoading = false;
        });
      } else {
        // Regular employees can only see their own time logs
        setState(() {
          _myTimeLogs = myTimeLogs;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load time logs: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _showAddTimeLogDialog() async {
    final timeLogService = Provider.of<TimeLogService>(context, listen: false);
    
    await showDialog(
      context: context,
      builder: (context) => TimeLogFormDialog(
        onSave: (timeLog) async {
          try {
            await timeLogService.createTimeLog(timeLog);
            _loadTimeLogs(); // Reload the time logs
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Time log added successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding time log: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }
  
  Future<void> _showEditTimeLogDialog(TimeLog timeLog) async {
    final timeLogService = Provider.of<TimeLogService>(context, listen: false);
    
    await showDialog(
      context: context,
      builder: (context) => TimeLogFormDialog(
        timeLog: timeLog,
        onSave: (updatedTimeLog) async {
          try {
            await timeLogService.updateTimeLog(updatedTimeLog);
            _loadTimeLogs(); // Reload the time logs
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Time log updated successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating time log: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }
  
  Future<void> _confirmDeleteTimeLog(TimeLog timeLog) async {
    final timeLogService = Provider.of<TimeLogService>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this time log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        if (timeLog.id != null) {
          await timeLogService.deleteTimeLog(timeLog.id!);
          _loadTimeLogs(); // Reload the time logs
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time log deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting time log: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _clockOut(TimeLog timeLog) async {
    final timeLogService = Provider.of<TimeLogService>(context, listen: false);
    
    if (timeLog.id == null) return;
    
    try {
      await timeLogService.clockOut(timeLog.id!);
      _loadTimeLogs(); // Reload the time logs
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clocked out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clocking out: ${e.toString()}')),
      );
    }
  }
  
  Widget _buildTimeLogs(List<TimeLog>? timeLogs, bool isPersonal) {
    final authService = Provider.of<AuthService>(context);
    
    if (timeLogs == null) {
      return const Center(child: Text('No time logs available'));
    }
    
    if (timeLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Time Logs Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isPersonal ? 'You have no time logs yet' : 'No time logs available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: timeLogs.length,
      itemBuilder: (context, index) {
        final timeLog = timeLogs[index];
        return TimeLogCard(
          timeLog: timeLog,
          authService: authService,
          onEdit: () => _showEditTimeLogDialog(timeLog),
          onDelete: () => _confirmDeleteTimeLog(timeLog),
          onClockOut: timeLog.timeOut == null ? () => _clockOut(timeLog) : null,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bool isAdminOrLead = authService.hasRole(UserRole.lead);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Logs'),
        bottom: isAdminOrLead
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Time Logs'),
                  Tab(text: 'My Time Logs'),
                ],
              )
            : null,
      ),
      drawer: const AppDrawer(currentRoute: '/timelogs'),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? ErrorDisplay(message: _errorMessage!, onRetry: _loadTimeLogs)
              : isAdminOrLead
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTimeLogs(_allTimeLogs, false), // All time logs
                        _buildTimeLogs(_myTimeLogs, true), // My time logs
                      ],
                    )
                  : _buildTimeLogs(_myTimeLogs, true), // Only my time logs for regular employees
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimeLogDialog,
        tooltip: 'Add Time Log',
        child: const Icon(Icons.add),
      ),
    );
  }
} 