import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 'admin_default_id',
      'name': 'Aimin Admin',
      'email': 'admin@gachamerch.com',
      'password': 'password123',
      'role': 'admin',
    },
    {
      'id': 'user_default_id',
      'name': 'Tabibito User',
      'email': 'user@gachamerch.com',
      'password': 'password123',
      'role': 'user',
    }
  ];

  static Future<List<dynamic>> _loadAllUsers(SharedPreferences prefs) async {
    final usersStr = prefs.getString('mock_users');
    if (usersStr == null) {
      await prefs.setString('mock_users', jsonEncode(_defaultUsers));
      return _defaultUsers;
    }
    final List<dynamic> list = jsonDecode(usersStr);
    bool changed = false;
    for (var defUser in _defaultUsers) {
      if (!list.any((u) => u['email'].toString().toLowerCase() == defUser['email'].toString().toLowerCase())) {
        list.add(defUser);
        changed = true;
      }
    }
    if (changed) {
      await prefs.setString('mock_users', jsonEncode(list));
    }
    return list;
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    // Artificial delay to simulate network latency
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> usersJson = await _loadAllUsers(prefs);

    // Check if email already exists
    if (usersJson.any((u) => u['email'].toString().toLowerCase() == email.toLowerCase())) {
      throw Exception('Email is already registered!');
    }

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'password': password, // simple plaintext check for mock
      'role': email.contains('admin') ? 'admin' : 'user',
    };

    usersJson.add(newUser);
    await prefs.setString('mock_users', jsonEncode(usersJson));

    return {
      'message': 'Registrasi berhasil!',
      'user': {
        'id': newUser['id'],
        'name': newUser['name'],
        'email': newUser['email'],
        'role': newUser['role'],
      }
    };
  }

  static Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> usersJson = await _loadAllUsers(prefs);

    // Find user
    dynamic matchedUser;
    for (var u in usersJson) {
      if (u['email'].toString().toLowerCase() == email.toLowerCase() && u['password'] == password) {
        matchedUser = u;
        break;
      }
    }

    if (matchedUser == null) {
      throw Exception('Email atau password salah!');
    }

    await ApiService.saveToken('mock_jwt_token_${matchedUser['id']}');

    return User(
      id: matchedUser['id'],
      name: matchedUser['name'],
      email: matchedUser['email'],
      role: matchedUser['role'],
    );
  }

  static Future<User> oauth(String email, String name, String oauthId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString('mock_users') ?? '[]';
    final List<dynamic> usersJson = jsonDecode(usersStr);

    dynamic matchedUser;
    for (var u in usersJson) {
      if (u['email'].toString().toLowerCase() == email.toLowerCase()) {
        matchedUser = u;
        break;
      }
    }

    if (matchedUser == null) {
      matchedUser = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'password': 'oauth_user_pass_no_login',
        'role': email.contains('admin') ? 'admin' : 'user',
      };
      usersJson.add(matchedUser);
      await prefs.setString('mock_users', jsonEncode(usersJson));
    }

    await ApiService.saveToken('mock_jwt_token_${matchedUser['id']}');

    return User(
      id: matchedUser['id'],
      name: matchedUser['name'],
      email: matchedUser['email'],
      role: matchedUser['role'],
    );
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await ApiService.removeToken();
  }
}
