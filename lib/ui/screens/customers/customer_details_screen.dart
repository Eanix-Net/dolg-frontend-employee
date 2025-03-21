import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/customer.dart';
import '../../../core/models/customer_location.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/customer_service.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_display.dart';
import '../../widgets/location_card.dart';
import '../../widgets/location_form.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final int customerId;
  
  const CustomerDetailsScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  Customer? _customer;
  List<CustomerLocation>? _locations;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }
  
  Future<void> _loadCustomerData() async {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Load customer and locations
      final customer = await customerService.getCustomer(widget.customerId);
      
      if (customer != null) {
        final locations = await customerService.getCustomerLocations(widget.customerId);
        
        setState(() {
          _customer = customer;
          _locations = locations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Customer not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading customer: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  void _showAddLocationDialog() {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Location'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: LocationForm(
              customerId: widget.customerId,
              onSubmit: (location) async {
                Navigator.of(context).pop();
                try {
                  await customerService.createCustomerLocation(location);
                  _loadCustomerData(); // Reload to show the new location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding location: ${e.toString()}')),
                  );
                }
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: EdgeInsets.zero,
        actions: const [],
      ),
    );
  }
  
  void _showEditLocationDialog(CustomerLocation location) {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Location'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: LocationForm(
              customerId: widget.customerId,
              location: location,
              onSubmit: (updatedLocation) async {
                Navigator.of(context).pop();
                try {
                  await customerService.updateCustomerLocation(updatedLocation);
                  _loadCustomerData(); // Reload to show the updated location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating location: ${e.toString()}')),
                  );
                }
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: EdgeInsets.zero,
        actions: const [],
      ),
    );
  }
  
  Future<void> _confirmDeleteLocation(CustomerLocation location) async {
    if (location.id == null) return;
    
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this location? This action cannot be undone.'),
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
        await customerService.deleteCustomerLocation(location.id!);
        _loadCustomerData(); // Reload to update the locations list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting location: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    final bool canAddEdit = authService.hasRole(UserRole.lead);
    final bool canDelete = authService.hasRole(UserRole.admin);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_customer?.name ?? 'Customer Details'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadCustomerData,
                )
              : _customer == null
                  ? const Center(child: Text('Customer not found'))
                  : RefreshIndicator(
                      onRefresh: _loadCustomerData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer info card
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Theme.of(context).primaryColor,
                                          child: Text(
                                            _customer!.name.isNotEmpty ? _customer!.name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _customer!.name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (_customer!.createdDateTime != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Customer since ${_customer!.createdDateTime!.year}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 32),
                                    // Contact info
                                    if (_customer!.email.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.email, size: 18, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            _customer!.email,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (_customer!.phone != null && _customer!.phone!.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 18, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            _customer!.phone!,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    // Notes
                                    if (_customer!.notes != null && _customer!.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Notes:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _customer!.notes!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            
                            // Locations section
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Locations',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (canAddEdit)
                                  ElevatedButton.icon(
                                    onPressed: _showAddLocationDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Location'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Locations list
                            if (_locations == null || _locations!.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No locations found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (canAddEdit) ...[
                                        const SizedBox(height: 16),
                                        TextButton.icon(
                                          onPressed: _showAddLocationDialog,
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add a location'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _locations!.length,
                                itemBuilder: (context, index) {
                                  final location = _locations![index];
                                  return LocationCard(
                                    location: location,
                                    onEdit: canAddEdit ? () => _showEditLocationDialog(location) : null,
                                    onDelete: canDelete ? () => _confirmDeleteLocation(location) : null,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
    );
  }
} 