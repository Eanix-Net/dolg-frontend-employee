import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/customer.dart';
import '../../core/models/invoice.dart';
import '../../core/models/invoice_item.dart';
import '../../core/services/customer_service.dart';

class InvoiceForm extends StatefulWidget {
  final Invoice? invoice;
  final int? customerId;
  final Function(Invoice) onSave;
  
  const InvoiceForm({
    super.key,
    this.invoice,
    this.customerId,
    required this.onSave,
  });

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingCustomers = false;
  List<Customer> _customers = [];
  String? _errorMessage;
  
  // Form fields
  int? _selectedCustomerId;
  late TextEditingController _invoiceNumberController;
  late DateTime _issueDate;
  late DateTime _dueDate;
  late TextEditingController _notesController;
  List<InvoiceItem> _items = [];
  double _total = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers and fields
    if (widget.invoice != null) {
      _selectedCustomerId = widget.invoice!.customerId;
      _invoiceNumberController = TextEditingController(text: widget.invoice!.invoiceNumber);
      _issueDate = widget.invoice!.issueDate;
      _dueDate = widget.invoice!.dueDate;
      _notesController = TextEditingController(text: widget.invoice!.notes);
      _items = widget.invoice!.items?.toList() ?? [];
    } else {
      _selectedCustomerId = widget.customerId;
      _invoiceNumberController = TextEditingController();
      _issueDate = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 30));
      _notesController = TextEditingController();
      _items = [];
    }
    
    _loadCustomers();
    _calculateTotal();
  }
  
  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCustomers() async {
    if (_isLoadingCustomers) return;
    
    setState(() {
      _isLoadingCustomers = true;
      _errorMessage = null;
    });
    
    try {
      final customerService = Provider.of<CustomerService>(context, listen: false);
      await customerService.getCustomers();
      
      setState(() {
        _customers = customerService.customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
        _errorMessage = 'Failed to load customers: ${e.toString()}';
      });
    }
  }
  
  void _calculateTotal() {
    double total = 0.0;
    for (var item in _items) {
      total += item.amount;
    }
    setState(() {
      _total = total;
    });
  }
  
  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final currentDate = isIssueDate ? _issueDate : _dueDate;
    final firstDate = isIssueDate ? DateTime.now().subtract(const Duration(days: 365)) : _issueDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = pickedDate;
          // Adjust due date if it's before the issue date
          if (_dueDate.isBefore(_issueDate)) {
            _dueDate = _issueDate.add(const Duration(days: 30));
          }
        } else {
          _dueDate = pickedDate;
        }
      });
    }
  }
  
  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _InvoiceItemDialog(
        onSave: (item) {
          setState(() {
            _items.add(item);
          });
          _calculateTotal();
        },
      ),
    );
  }
  
  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _InvoiceItemDialog(
        item: _items[index],
        onSave: (item) {
          setState(() {
            _items[index] = item;
          });
          _calculateTotal();
        },
      ),
    );
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _calculateTotal();
  }
  
  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item to the invoice')),
        );
        return;
      }
      
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final invoice = Invoice(
          id: widget.invoice?.id,
          customerId: _selectedCustomerId!,
          customerName: _customers.firstWhere((c) => c.id == _selectedCustomerId).name,
          invoiceNumber: _invoiceNumberController.text.isEmpty ? null : _invoiceNumberController.text,
          issueDate: _issueDate,
          dueDate: _dueDate,
          status: widget.invoice?.status ?? InvoiceStatus.draft,
          total: _total,
          amountPaid: widget.invoice?.amountPaid ?? 0.0,
          balance: widget.invoice?.balance ?? _total,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          items: _items,
          createdAt: widget.invoice?.createdAt,
          updatedAt: DateTime.now(),
        );
        
        widget.onSave(invoice);
        
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to save invoice: ${e.toString()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.invoice == null ? 'Create Invoice' : 'Edit Invoice',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _buildCustomerField(),
                const SizedBox(height: 16),
                _buildInvoiceDetails(),
                const SizedBox(height: 24),
                _buildItemsSection(),
                const SizedBox(height: 24),
                _buildTotalSection(),
                const SizedBox(height: 24),
                _buildNotesField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCustomerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _isLoadingCustomers
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select Customer',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCustomerId,
                items: _customers.map((customer) {
                  return DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: widget.invoice != null ? null : (int? value) {
                  setState(() {
                    _selectedCustomerId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              ),
        if (_errorMessage != null && _errorMessage!.contains('customer'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
  
  Widget _buildInvoiceDetails() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice Number',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(
                  hintText: 'Auto-generated',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issue Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_issueDate)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_dueDate)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _items.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'No items added yet. Click "Add Item" to add services or products to this invoice.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final currencyFormat = NumberFormat.currency(symbol: '\$');
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.description),
                      subtitle: Text('${item.quantity} × ${currencyFormat.format(item.unitPrice)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyFormat.format(item.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editItem(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
  
  Widget _buildTotalSection() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              currencyFormat.format(_total),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Add notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _saveInvoice,
        child: Text(
          widget.invoice == null ? 'Create Invoice' : 'Save Changes',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _InvoiceItemDialog extends StatefulWidget {
  final InvoiceItem? item;
  final Function(InvoiceItem) onSave;
  
  const _InvoiceItemDialog({
    this.item,
    required this.onSave,
  });

  @override
  State<_InvoiceItemDialog> createState() => _InvoiceItemDialogState();
}

class _InvoiceItemDialogState extends State<_InvoiceItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _amountController;
  
  @override
  void initState() {
    super.initState();
    
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _unitPriceController = TextEditingController(
      text: widget.item?.unitPrice.toString() ?? '0.00',
    );
    _amountController = TextEditingController(
      text: widget.item?.amount.toString() ?? '0.00',
    );
    
    // Calculate total if creating a new item
    if (widget.item == null) {
      _calculateAmount();
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  void _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final amount = quantity * unitPrice;
    
    _amountController.text = amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null ? 'Add Item' : 'Edit Item',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _calculateAmount(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final quantity = double.tryParse(value);
                          if (quantity == null) {
                            return 'Invalid number';
                          }
                          if (quantity <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _calculateAmount(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final price = double.tryParse(value);
                          if (price == null) {
                            return 'Invalid number';
                          }
                          if (price < 0) {
                            return 'Must be >= 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final item = InvoiceItem(
                            id: widget.item?.id,
                            invoiceId: widget.item?.invoiceId,
                            description: _descriptionController.text,
                            quantity: double.parse(_quantityController.text),
                            unitPrice: double.parse(_unitPriceController.text),
                            amount: double.parse(_amountController.text),
                          );
                          
                          widget.onSave(item);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 