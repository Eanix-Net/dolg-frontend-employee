import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/equipment.dart';
import '../models/equipment_category.dart';

class EquipmentService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  List<Equipment> _equipment = [];
  List<EquipmentCategory> _categories = [];

  EquipmentService(this._apiService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Equipment> get equipment => _equipment;
  List<EquipmentCategory> get categories => _categories;

  Future<List<Equipment>> getEquipment() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/equipment');
      _equipment = (response as List)
          .map((json) => Equipment.fromJson(json))
          .toList();
      _setError(null);
      return _equipment;
    } catch (e) {
      _setError('Failed to load equipment: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Equipment?> getEquipmentItem(int id) async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/equipment/$id');
      final equipmentItem = Equipment.fromJson(response);
      _setError(null);
      return equipmentItem;
    } catch (e) {
      _setError('Failed to load equipment item: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<EquipmentCategory>> getCategories() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/equipment/categories');
      _categories = (response as List)
          .map((json) => EquipmentCategory.fromJson(json))
          .toList();
      _setError(null);
      return _categories;
    } catch (e) {
      _setError('Failed to load equipment categories: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Equipment?> createEquipment(Equipment equipment) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        '/equipment',
        data: equipment.toJson(),
      );
      final newEquipment = Equipment.fromJson(response);
      _equipment.add(newEquipment);
      notifyListeners();
      _setError(null);
      return newEquipment;
    } catch (e) {
      _setError('Failed to create equipment: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Equipment?> updateEquipment(Equipment equipment) async {
    _setLoading(true);
    try {
      final response = await _apiService.put(
        '/equipment/${equipment.id}',
        data: equipment.toJson(),
      );
      final updatedEquipment = Equipment.fromJson(response);
      final index = _equipment.indexWhere((e) => e.id == equipment.id);
      if (index != -1) {
        _equipment[index] = updatedEquipment;
        notifyListeners();
      }
      _setError(null);
      return updatedEquipment;
    } catch (e) {
      _setError('Failed to update equipment: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEquipment(int id) async {
    _setLoading(true);
    try {
      await _apiService.delete('/equipment/$id');
      _equipment.removeWhere((e) => e.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Failed to delete equipment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) {
      notifyListeners();
    }
  }
} 