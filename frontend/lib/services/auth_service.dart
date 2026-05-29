import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static void _handleResponseError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Terjadi kesalahan pada server (Status: ${response.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan pada server (Status: ${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    _handleResponseError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    _handleResponseError(response);
    final responseData = jsonDecode(response.body);
    final String token = responseData['token'];
    await ApiService.saveToken(token);
    return User.fromJson(responseData['user']);
  }

  static Future<User> oauth(String email, String name, String oauthId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/oauth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'oauth_id': oauthId,
      }),
    );
    _handleResponseError(response);
    final responseData = jsonDecode(response.body);
    final String token = responseData['token'];
    await ApiService.saveToken(token);
    return User.fromJson(responseData['user']);
  }

  static Future<void> logout() async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/logout'),
        headers: headers,
      );
      _handleResponseError(response);
    } catch (_) {}
    await ApiService.removeToken();
  }
}
