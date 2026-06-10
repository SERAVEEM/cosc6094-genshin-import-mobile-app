import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isChecking = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        _user = await AuthService.me();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', jsonEncode(_user!.toJson()));
      }
    } catch (_) {
      await ApiService.removeToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user');
      _user = null;
    }
    _isChecking = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AuthService.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(_user!.toJson()));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.register(name, email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginOauth(String email, String name, String oauthId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AuthService.oauth(email, name, oauthId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user', jsonEncode(_user!.toJson()));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.logout();
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
