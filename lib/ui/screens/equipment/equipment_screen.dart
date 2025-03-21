import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/equipment_service.dart';
import '../../../core/models/equipment.dart';
import '../../common/app_drawer.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_display.dart';
import 'equipment_detail_screen.dart';
import 'equipment_form.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  late EquipmentService _equipmentService;
  late AuthService _authService;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _equipmentService = Provider.of<EquipmentService>(context);
      _authService = Provider.of<AuthService>(context);
      _loadEquipment();
      _isInit = true;
    }
  }

  Future<void> _loadEquipment() async {
    await _equipmentService.getEquipment();
  }

  @override
  Widget build(BuildContext context) {
    final bool canEditEquipment = _authService.hasRole(UserRole.lead);
    final bool canDeleteEquipment = _authService.hasRole(UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
      ),
      drawer: const AppDrawer(currentRoute: '/equipment'),
      body: RefreshIndicator(
        onRefresh: _loadEquipment,
        child: _buildBody(canEditEquipment, canDeleteEquipment),
      ),
      floatingActionButton: canEditEquipment
          ? FloatingActionButton(
              onPressed: () => _showEquipmentForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(bool canEdit, bool canDelete) {
    if (_equipmentService.isLoading) {
      return const LoadingIndicator();
    }
    
    if (_equipmentService.error != null) {
      return ErrorDisplay(
        message: _equipmentService.error!,
        onRetry: _loadEquipment,
      );
    }

    final equipment = _equipmentService.equipment;
    
    if (equipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Equipment Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              canEdit 
                ? 'Add equipment using the + button below'
                : 'No equipment has been added yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equipment.length,
      itemBuilder: (context, index) {
        final item = equipment[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getEquipmentIcon(item),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(item.name),
            subtitle: Text(
              '${item.manufacturer ?? 'Unknown'} ${item.model ?? ''}' +
              (item.category != null ? ' • ${item.category!.name}' : ''),
            ),
            trailing: canEdit
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEquipmentForm(context, item),
                  )
                : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentDetailScreen(
                  equipment: item,
                  canEdit: canEdit,
                  canDelete: canDelete,
                ),
              ),
            ),
            onLongPress: canDelete
                ? () => _confirmDelete(context, item)
                : null,
          ),
        );
      },
    );
  }

  IconData _getEquipmentIcon(Equipment equipment) {
    // Determine icon based on equipment category or fuel type
    if (equipment.fuelType == FuelType.electric) {
      return Icons.electrical_services;
    } else if (equipment.fuelType == FuelType.gas || equipment.fuelType == FuelType.diesel) {
      return Icons.local_gas_station;
    }
    return Icons.build;
  }

  Future<void> _showEquipmentForm(BuildContext context, [Equipment? equipment]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentForm(equipment: equipment),
      ),
    );
    // Refresh equipment list after returning from form
    _loadEquipment();
  }

  Future<void> _confirmDelete(BuildContext context, Equipment equipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text('Are you sure you want to delete ${equipment.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _equipmentService.deleteEquipment(equipment.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${equipment.name} deleted')),
        );
      }
    }
  }
} 