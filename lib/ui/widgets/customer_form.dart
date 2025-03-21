import 'package:flutter/material.dart';
import '../../core/models/customer.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSubmit;
  final VoidCallback onCancel;
  
  const CustomerForm({
    Key? key,
    this.customer,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.customer != null;
    
    _nameController = TextEditingController(text: _isEditMode ? widget.customer!.name : '');
    _emailController = TextEditingController(text: _isEditMode ? widget.customer!.email : '');
    _phoneController = TextEditingController(text: _isEditMode ? widget.customer!.phone ?? '' : '');
    _notesController = TextEditingController(text: _isEditMode ? widget.customer!.notes ?? '' : '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: _isEditMode ? widget.customer!.id : null,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
        createdDateTime: _isEditMode ? widget.customer!.createdDateTime : DateTime.now(),
        locations: _isEditMode ? widget.customer!.locations : null,
      );
      
      widget.onSubmit(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an email';
              }
              
              // Simple email validation
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          // Notes field
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditMode ? 'UPDATE' : 'SAVE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 