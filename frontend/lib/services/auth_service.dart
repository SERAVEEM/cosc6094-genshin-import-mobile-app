import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('${ApiService.baseUrl}/auth/register');
    final response = await http.post(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal mendaftar akun!');
    }
    return data;
  }

  static Future<User> login(String email, String password) async {
    final url = Uri.parse('${ApiService.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Email atau password salah!');
    }
    
    final token = data['token'] as String;
    await ApiService.saveToken(token);
    
    return User.fromJson(data['user']);
  }

  static Future<User> oauth(String email, String name, String oauthId) async {
    final url = Uri.parse('${ApiService.baseUrl}/auth/oauth');
    final response = await http.post(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'email': email,
        'name': name,
        'oauth_id': oauthId,
      }),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login OAuth gagal!');
    }
    
    final token = data['token'] as String;
    await ApiService.saveToken(token);
    
    return User.fromJson(data['user']);
  }

  static Future<void> logout() async {
    final url = Uri.parse('${ApiService.baseUrl}/auth/logout');
    try {
      await http.post(url, headers: await ApiService.getHeaders());
    } catch (_) {}
    await ApiService.removeToken();
  }
}
