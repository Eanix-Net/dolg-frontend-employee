import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/invoice.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/invoice_service.dart';
import '../../common/app_drawer.dart';
import 'invoice_details_screen.dart';
import '../../widgets/invoice_form.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  
  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }
  
  Future<void> _loadInvoices() async {
    final invoiceService = Provider.of<InvoiceService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await invoiceService.getInvoices();
      
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
  
  void _navigateToInvoiceDetails(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailsScreen(invoiceId: invoice.id!),
      ),
    ).then((_) => _loadInvoices());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final invoiceService = Provider.of<InvoiceService>(context);
    final invoices = invoiceService.invoices;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          if (authService.hasRole(UserRole.lead))
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterOptions,
              tooltip: 'Filter Invoices',
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'invoices'),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
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
                        onPressed: _loadInvoices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildInvoicesList(invoices),
      floatingActionButton: authService.hasRole(UserRole.lead)
          ? FloatingActionButton(
              onPressed: _createInvoice,
              tooltip: 'Create Invoice',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildInvoicesList(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(
        child: Text('No invoices found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }
  
  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);
    final statusText = _getStatusText(invoice.status);
    final formattedDate = DateFormat('MMM d, yyyy').format(invoice.issueDate);
    final formattedAmount = NumberFormat.currency(symbol: '\$').format(invoice.total);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToInvoiceDetails(invoice),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.customerName ?? 'Unknown Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoice #${invoice.invoiceNumber ?? invoice.id}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:'),
                  Text(
                    formattedAmount,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (invoice.amountPaid > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paid:'),
                    Text(
                      _currencyFormat.format(invoice.amountPaid),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
              if (invoice.balance > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Balance:'),
                    Text(
                      _currencyFormat.format(invoice.balance),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Due: ${_dateFormat.format(invoice.dueDate)}',
                    style: TextStyle(
                      color: _isDueOrOverdue(invoice.dueDate) ? Colors.red : Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  bool _isDueOrOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return now.isAfter(dueDate) || 
           now.year == dueDate.year && 
           now.month == dueDate.month && 
           now.day == dueDate.day;
  }
  
  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.canceled:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }
  
  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.canceled:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Invoices'),
              onTap: () {
                Navigator.pop(context);
                _loadInvoices();
              },
            ),
            ListTile(
              title: const Text('Paid Invoices'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement filter logic
              },
            ),
            ListTile(
              title: const Text('Unpaid Invoices'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement filter logic
              },
            ),
            ListTile(
              title: const Text('Overdue Invoices'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement filter logic
              },
            ),
          ],
        );
      },
    );
  }
  
  void _createInvoice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Invoice'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: InvoiceForm(
            onSave: (invoice) async {
              Navigator.pop(context);
              
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              
              try {
                final invoiceService = Provider.of<InvoiceService>(context, listen: false);
                await invoiceService.createInvoice(invoice);
                
                _loadInvoices();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice created successfully')),
                  );
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = e.toString();
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
} 