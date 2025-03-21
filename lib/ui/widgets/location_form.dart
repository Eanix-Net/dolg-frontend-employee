import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/customer_location.dart';

class LocationForm extends StatefulWidget {
  final int customerId;
  final CustomerLocation? location;
  final Function(CustomerLocation) onSubmit;
  final VoidCallback onCancel;
  
  const LocationForm({
    Key? key,
    required this.customerId,
    this.location,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _addressController;
  late final TextEditingController _pointOfContactController;
  late final TextEditingController _acresController;
  late final TextEditingController _notesController;
  
  PropertyType _propertyType = PropertyType.residential;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.location != null;
    
    _addressController = TextEditingController(text: _isEditMode ? widget.location!.address ?? '' : '');
    _pointOfContactController = TextEditingController(text: _isEditMode ? widget.location!.pointOfContact ?? '' : '');
    _acresController = TextEditingController(
      text: _isEditMode && widget.location!.approxAcres != null 
        ? widget.location!.approxAcres.toString() 
        : ''
    );
    _notesController = TextEditingController(text: _isEditMode ? widget.location!.notes ?? '' : '');
    
    if (_isEditMode && widget.location!.propertyType != null) {
      _propertyType = widget.location!.propertyType!;
    }
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    _pointOfContactController.dispose();
    _acresController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      double? acres;
      if (_acresController.text.isNotEmpty) {
        acres = double.tryParse(_acresController.text);
      }
      
      final location = CustomerLocation(
        id: _isEditMode ? widget.location!.id : null,
        customerId: widget.customerId,
        address: _addressController.text.trim(),
        pointOfContact: _pointOfContactController.text.trim(),
        propertyType: _propertyType,
        approxAcres: acres,
        notes: _notesController.text.trim(),
      );
      
      widget.onSubmit(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Address field
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Point of contact field
          TextFormField(
            controller: _pointOfContactController,
            decoration: const InputDecoration(
              labelText: 'Point of Contact (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          
          // Property type
          DropdownButtonFormField<PropertyType>(
            value: _propertyType,
            decoration: const InputDecoration(
              labelText: 'Property Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            items: PropertyType.values.map((type) {
              return DropdownMenuItem<PropertyType>(
                value: type,
                child: Text(type == PropertyType.residential ? 'Residential' : 'Business'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _propertyType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Approximate acres field
          TextFormField(
            controller: _acresController,
            decoration: const InputDecoration(
              labelText: 'Approximate Acres (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.crop_square),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid positive number';
                }
              }
              return null;
            },
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