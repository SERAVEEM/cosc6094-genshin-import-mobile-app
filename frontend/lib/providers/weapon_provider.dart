import 'package:flutter/material.dart';
import '../models/weapon.dart';
import '../services/weapon_service.dart';

class WeaponProvider with ChangeNotifier {
  List<Weapon> _weapons = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'All'; // 'All', 'Claymore', 'Sword', 'Catalyst', 'Bow'
  String _searchQuery = '';

  List<Weapon> get weapons {
    return _weapons.where((weapon) {
      final matchesCategory = _selectedCategory == 'All' || 
          weapon.type.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = weapon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          weapon.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Weapon> get rawWeapons => _weapons;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _weapons = await WeaponService.getCatalog();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> createWeapon(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newWeapon = await WeaponService.createWeapon(data);
      _weapons.add(newWeapon);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWeapon(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await WeaponService.updateWeapon(id, data);
      final index = _weapons.indexWhere((w) => w.id == id);
      if (index != -1) {
        _weapons[index] = updated;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWeapon(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await WeaponService.deleteWeapon(id);
      _weapons.removeWhere((w) => w.id == id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
