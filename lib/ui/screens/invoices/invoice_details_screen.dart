import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/invoice_service.dart';
import '../../../core/models/invoice.dart';
import '../../../core/models/invoice_item.dart';
import '../../../core/models/payment.dart';
import '../../widgets/invoice_form.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;
  
  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> with SingleTickerProviderStateMixin {
  Invoice? _invoice;
  List<Payment> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMMM d, yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvoiceData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInvoiceData() async {
    final invoiceService = Provider.of<InvoiceService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final invoice = await invoiceService.getInvoice(widget.invoiceId);
      final payments = await invoiceService.getInvoicePayments(widget.invoiceId);
      
      setState(() {
        _invoice = invoice;
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  
  void _showAddPaymentDialog() {
    if (_invoice == null) return;
    
    final formKey = GlobalKey<FormState>();
    double amount = _invoice!.balance;
    PaymentMethod method = PaymentMethod.cash;
    String? reference;
    String? notes;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Payment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      hintText: _currencyFormat.format(_invoice!.balance).substring(1), // Remove $
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    initialValue: amount.toString(),
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? 0.0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Please enter a valid number';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      if (amount > _invoice!.balance) {
                        return 'Amount cannot exceed the remaining balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PaymentMethod>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
                    value: method,
                    items: PaymentMethod.values.map((paymentMethod) {
                      return DropdownMenuItem<PaymentMethod>(
                        value: paymentMethod,
                        child: Text(_getPaymentMethodText(paymentMethod)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        method = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Reference Number (Optional)',
                      hintText: 'Check #, Transaction ID, etc.',
                    ),
                    onChanged: (value) {
                      reference = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      notes = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            
                            final payment = Payment(
                              invoiceId: _invoice!.id!,
                              amount: amount,
                              paymentDate: DateTime.now(),
                              paymentMethod: method,
                              referenceNumber: reference,
                              notes: notes,
                            );
                            
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              await Provider.of<InvoiceService>(context, listen: false)
                                  .addPayment(payment);
                              
                              await _loadInvoiceData();
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Payment added successfully')),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = 'Failed to add payment: ${e.toString()}';
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Add Payment'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.check:
        return 'Check';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debit:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.other:
        return 'Other';
      default:
        return 'Unknown';
    }
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          if (authService.hasRole(UserRole.lead) && _invoice != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editInvoice();
                } else if (value == 'delete') {
                  _confirmDeleteInvoice();
                } else if (value == 'mark_paid') {
                  _showAddPaymentDialog();
                } else if (value == 'mark_sent') {
                  _markInvoiceAsSent();
                } else if (value == 'print') {
                  // TODO: Implement print invoice
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Invoice'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_paid',
                  child: Row(
                    children: [
                      Icon(Icons.payment),
                      SizedBox(width: 8),
                      Text('Add Payment'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_sent',
                  child: Row(
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text('Mark as Sent'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print),
                      SizedBox(width: 8),
                      Text('Print Invoice'),
                    ],
                  ),
                ),
                if (authService.hasRole(UserRole.admin))
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Invoice', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Payments'),
          ],
        ),
      ),
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
                        onPressed: _loadInvoiceData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _invoice == null
                  ? const Center(child: Text('Invoice not found'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(),
                        _buildPaymentsTab(),
                      ],
                    ),
      floatingActionButton: _tabController.index == 1 && 
                            _invoice != null && 
                            _invoice!.balance > 0 && 
                            authService.hasRole(UserRole.lead)
          ? FloatingActionButton(
              onPressed: _showAddPaymentDialog,
              tooltip: 'Add Payment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildDetailsTab() {
    if (_invoice == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceHeader(),
          const SizedBox(height: 24),
          _buildInvoiceInfo(),
          const SizedBox(height: 24),
          if (_invoice!.items != null && _invoice!.items!.isNotEmpty)
            _buildInvoiceItems(),
          const SizedBox(height: 24),
          _buildTotalsSection(),
        ],
      ),
    );
  }
  
  Widget _buildInvoiceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice #${_invoice!.invoiceNumber ?? _invoice!.id}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                _invoice!.customerName ?? 'Unknown Customer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(_invoice!.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _getStatusColor(_invoice!.status)),
          ),
          child: Text(
            _getStatusText(_invoice!.status),
            style: TextStyle(
              color: _getStatusColor(_invoice!.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInvoiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Issue Date'),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(_invoice!.issueDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date'),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(_invoice!.dueDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _invoice!.dueDate.isBefore(DateTime.now()) &&
                                 _invoice!.status != InvoiceStatus.paid
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_invoice!.notes != null && _invoice!.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Notes'),
              const SizedBox(height: 4),
              Text(_invoice!.notes!),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInvoiceItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                ...(_invoice!.items ?? []).map((item) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(item.description),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(item.quantity.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_currencyFormat.format(item.unitPrice)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_currencyFormat.format(item.amount)),
                    ),
                  ],
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTotalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(
                  _currencyFormat.format(_invoice!.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount Paid:'),
                Text(
                  _currencyFormat.format(_invoice!.amountPaid),
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance Due:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _currencyFormat.format(_invoice!.balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _invoice!.balance > 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentsTab() {
    return _payments.isEmpty
        ? const Center(child: Text('No payments recorded for this invoice'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dateFormat.format(payment.paymentDate),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _currencyFormat.format(payment.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Method: ${_getPaymentMethodText(payment.paymentMethod)}'),
                      if (payment.referenceNumber != null) ...[
                        const SizedBox(height: 4),
                        Text('Reference: ${payment.referenceNumber}'),
                      ],
                      if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${payment.notes}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }
  
  void _confirmDeleteInvoice() {
    if (_invoice == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete this invoice (${_invoice!.invoiceNumber ?? _invoice!.id})? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                setState(() {
                  _isLoading = true;
                });
                
                final success = await Provider.of<InvoiceService>(context, listen: false)
                    .deleteInvoice(_invoice!.id!);
                
                if (success && mounted) {
                  Navigator.pop(context); // Go back to invoice list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice deleted successfully')),
                  );
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to delete invoice: ${e.toString()}';
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editInvoice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Invoice'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: InvoiceForm(
            invoice: _invoice,
            onSave: (invoice) async {
              Navigator.pop(context);
              
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              
              try {
                final invoiceService = Provider.of<InvoiceService>(context, listen: false);
                await invoiceService.updateInvoice(invoice);
                
                await _loadInvoiceData();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice updated successfully')),
                  );
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to update invoice: ${e.toString()}';
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

  void _markInvoiceAsSent() {
    if (_invoice == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final updatedInvoice = _invoice!.copyWith(
        status: InvoiceStatus.sent,
        updatedAt: DateTime.now(),
      );
      
      Provider.of<InvoiceService>(context, listen: false)
          .updateInvoice(updatedInvoice)
          .then((_) {
            _loadInvoiceData();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice marked as sent')),
              );
            }
          })
          .catchError((e) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to update invoice: ${e.toString()}';
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update invoice: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
} 