import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/equipment.dart';
import '../../../core/services/equipment_service.dart';
import 'equipment_form.dart';

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipment;
  final bool canEdit;
  final bool canDelete;

  const EquipmentDetailScreen({
    Key? key,
    required this.equipment,
    required this.canEdit,
    required this.canDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipment.name),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditForm(context),
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard(context),
              const SizedBox(height: 16),
              _buildSpecificationsCard(context),
              const SizedBox(height: 16),
              _buildPurchaseInfoCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, 'Equipment Name', equipment.name),
            if (equipment.category != null)
              _buildInfoRow(context, 'Category', equipment.category!.name),
            if (equipment.manufacturer != null)
              _buildInfoRow(context, 'Manufacturer', equipment.manufacturer!),
            if (equipment.model != null)
              _buildInfoRow(context, 'Model', equipment.model!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (equipment.fuelType != null)
              _buildInfoRow(
                context, 
                'Fuel Type', 
                _getFuelTypeDisplay(equipment.fuelType!),
              ),
            if (equipment.oilType != null)
              _buildInfoRow(context, 'Oil Type', equipment.oilType!),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (equipment.purchasedDate != null)
              _buildInfoRow(
                context, 
                'Purchase Date', 
                _formatDate(equipment.purchasedDate!),
              ),
            if (equipment.purchasePrice != null)
              _buildInfoRow(
                context, 
                'Purchase Price', 
                '\$${equipment.purchasePrice!.toStringAsFixed(2)}',
              ),
            if (equipment.purchasedCondition != null)
              _buildInfoRow(
                context, 
                'Condition', 
                _getConditionDisplay(equipment.purchasedCondition!),
              ),
            if (equipment.purchasedBy != null)
              _buildInfoRow(context, 'Purchased By', equipment.purchasedBy!),
            if (equipment.warrantyExpirationDate != null)
              _buildInfoRow(
                context, 
                'Warranty Expiration', 
                _formatDate(equipment.warrantyExpirationDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getFuelTypeDisplay(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gas:
        return 'Gas';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      default:
        return 'Unknown';
    }
  }

  String _getConditionDisplay(EquipmentCondition condition) {
    switch (condition) {
      case EquipmentCondition.newCondition:
        return 'New';
      case EquipmentCondition.usedCondition:
        return 'Used';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showEditForm(BuildContext context) {
    // This would be implemented in a separate widget for editing equipment
    // Will be part of equipment_form.dart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit form would be shown here')),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
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

    if (confirmed == true && equipment.id != null) {
      final equipmentService = Provider.of<EquipmentService>(context, listen: false);
      final success = await equipmentService.deleteEquipment(equipment.id!);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${equipment.name} deleted')),
        );
        Navigator.pop(context);
      }
    }
  }
} 