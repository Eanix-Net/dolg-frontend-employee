import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/customer.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/customer_service.dart';
import '../../common/app_drawer.dart';
import '../../common/loading_indicator.dart';
import '../../common/error_display.dart';
import '../../widgets/customer_list_item.dart';
import '../../widgets/customer_form.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer>? _searchResults;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    // Load customers when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCustomers() async {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    await customerService.getCustomers();
  }
  
  Future<void> _searchCustomers(String query) async {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      final results = await customerService.searchCustomers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching customers: ${e.toString()}')),
      );
    }
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = null;
      _isSearching = false;
    });
  }
  
  void _showAddCustomerDialog() {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: CustomerForm(
              onSubmit: (customer) async {
                Navigator.of(context).pop();
                try {
                  await customerService.createCustomer(customer);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding customer: ${e.toString()}')),
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
  
  void _showEditCustomerDialog(Customer customer) {
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: CustomerForm(
              customer: customer,
              onSubmit: (updatedCustomer) async {
                Navigator.of(context).pop();
                try {
                  await customerService.updateCustomer(updatedCustomer);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Customer updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating customer: ${e.toString()}')),
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
  
  Future<void> _confirmDeleteCustomer(Customer customer) async {
    if (customer.id == null) return;
    
    final customerService = Provider.of<CustomerService>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${customer.name}? This action cannot be undone and will delete all associated data.'),
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
        await customerService.deleteCustomer(customer.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting customer: ${e.toString()}')),
        );
      }
    }
  }
  
  void _navigateToCustomerDetails(Customer customer) {
    if (customer.id == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customerId: customer.id!),
      ),
    );
  }
  
  Widget _buildCustomersList(List<Customer> customers, bool canEdit, bool canDelete) {
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Customers Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchResults != null
                  ? 'Try a different search term'
                  : 'Add a new customer to get started',
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
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerListItem(
          customer: customer,
          onTap: () => _navigateToCustomerDetails(customer),
          onEdit: canEdit ? () => _showEditCustomerDialog(customer) : null,
          onDelete: canDelete ? () => _confirmDeleteCustomer(customer) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final customerService = Provider.of<CustomerService>(context);
    
    final bool canAddEdit = authService.hasRole(UserRole.lead);
    final bool canDelete = authService.hasRole(UserRole.admin);
    
    // Use search results if available, otherwise use the full list
    final displayedCustomers = _searchResults ?? customerService.customers;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          Navigator.of(context).pop();
                          if (value.isNotEmpty) {
                            _searchCustomers(value);
                          } else {
                            _clearSearch();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (_searchController.text.isNotEmpty) {
                            _searchCustomers(_searchController.text);
                          } else {
                            _clearSearch();
                          }
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/customers'),
      body: Column(
        children: [
          // Search indicator
          if (_searchResults != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.blue.shade100,
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search results for "${_searchController.text}" (${_searchResults!.length} found)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCustomers,
              child: customerService.isLoading
                  ? const Center(child: LoadingIndicator())
                  : customerService.errorMessage != null && !canAddEdit
                      ? ErrorDisplay(
                          message: customerService.errorMessage!,
                          onRetry: _loadCustomers,
                        )
                      : _isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : _buildCustomersList(displayedCustomers, canAddEdit, canDelete),
            ),
          ),
        ],
      ),
      floatingActionButton: canAddEdit
          ? FloatingActionButton(
              onPressed: _showAddCustomerDialog,
              tooltip: 'Add Customer',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 