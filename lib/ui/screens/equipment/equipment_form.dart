import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/equipment.dart';
import '../../../core/models/equipment_category.dart';
import '../../../core/services/equipment_service.dart';

class EquipmentForm extends StatefulWidget {
  final Equipment? equipment;

  const EquipmentForm({Key? key, this.equipment}) : super(key: key);

  @override
  State<EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _purchasedByController = TextEditingController();
  final _oilTypeController = TextEditingController();
  final _dateFormat = DateFormat('MM/dd/yyyy');
  
  DateTime? _purchasedDate;
  DateTime? _warrantyExpirationDate;
  EquipmentCondition? _purchasedCondition;
  FuelType? _fuelType;
  int? _categoryId;

  late EquipmentService _equipmentService;
  bool _isLoading = false;
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _initFormValues();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _equipmentService = Provider.of<EquipmentService>(context);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!_categoriesLoaded) {
      setState(() => _isLoading = true);
      await _equipmentService.getCategories();
      setState(() {
        _isLoading = false;
        _categoriesLoaded = true;
      });
    }
  }

  void _initFormValues() {
    final equipment = widget.equipment;
    if (equipment != null) {
      _nameController.text = equipment.name;
      _manufacturerController.text = equipment.manufacturer ?? '';
      _modelController.text = equipment.model ?? '';
      _purchasePriceController.text = equipment.purchasePrice?.toString() ?? '';
      _purchasedByController.text = equipment.purchasedBy ?? '';
      _oilTypeController.text = equipment.oilType ?? '';
      _purchasedDate = equipment.purchasedDate;
      _warrantyExpirationDate = equipment.warrantyExpirationDate;
      _purchasedCondition = equipment.purchasedCondition;
      _fuelType = equipment.fuelType;
      _categoryId = equipment.equipmentCategoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _purchasePriceController.dispose();
    _purchasedByController.dispose();
    _oilTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isWarrantyDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isWarrantyDate 
          ? (_warrantyExpirationDate ?? DateTime.now().add(const Duration(days: 365)))
          : (_purchasedDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isWarrantyDate) {
          _warrantyExpirationDate = pickedDate;
        } else {
          _purchasedDate = pickedDate;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final double? purchasePrice = _purchasePriceController.text.isNotEmpty
        ? double.tryParse(_purchasePriceController.text)
        : null;

    final equipment = Equipment(
      id: widget.equipment?.id,
      name: _nameController.text,
      manufacturer: _manufacturerController.text.isNotEmpty ? _manufacturerController.text : null,
      model: _modelController.text.isNotEmpty ? _modelController.text : null,
      purchasedDate: _purchasedDate,
      warrantyExpirationDate: _warrantyExpirationDate,
      purchasedCondition: _purchasedCondition,
      purchasePrice: purchasePrice,
      purchasedBy: _purchasedByController.text.isNotEmpty ? _purchasedByController.text : null,
      fuelType: _fuelType,
      oilType: _oilTypeController.text.isNotEmpty ? _oilTypeController.text : null,
      equipmentCategoryId: _categoryId,
    );

    try {
      if (widget.equipment == null) {
        await _equipmentService.createEquipment(equipment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment added successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        await _equipmentService.updateEquipment(equipment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment updated successfully')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipment == null ? 'Add Equipment' : 'Edit Equipment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Equipment Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter equipment name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Manufacturer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Purchase Date',
                      value: _purchasedDate,
                      onTap: () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purchasedByController,
                      decoration: const InputDecoration(
                        labelText: 'Purchased By',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConditionDropdown(),
                    const SizedBox(height: 16),
                    _buildFuelTypeDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _oilTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Oil Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Warranty Expiration Date',
                      value: _warrantyExpirationDate,
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.equipment == null ? 'Add Equipment' : 'Save Changes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null ? _dateFormat.format(value) : 'Select Date',
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _equipmentService.categories;
    
    return DropdownButtonFormField<int>(
      value: _categoryId,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        ...categories.map((category) => DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _categoryId = value;
        });
      },
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<EquipmentCondition>(
      value: _purchasedCondition,
      decoration: const InputDecoration(
        labelText: 'Condition',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: EquipmentCondition.newCondition,
          child: Text('New'),
        ),
        const DropdownMenuItem(
          value: EquipmentCondition.usedCondition,
          child: Text('Used'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _purchasedCondition = value;
        });
      },
    );
  }

  Widget _buildFuelTypeDropdown() {
    return DropdownButtonFormField<FuelType>(
      value: _fuelType,
      decoration: const InputDecoration(
        labelText: 'Fuel Type',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: FuelType.gas,
          child: Text('Gas'),
        ),
        const DropdownMenuItem(
          value: FuelType.diesel,
          child: Text('Diesel'),
        ),
        const DropdownMenuItem(
          value: FuelType.electric,
          child: Text('Electric'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _fuelType = value;
        });
      },
    );
  }
} 