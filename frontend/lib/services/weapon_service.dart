import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weapon.dart';
import 'api_service.dart';

class WeaponService {
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

  static Future<List<Weapon>> getCatalog() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/weapons'),
      headers: await ApiService.getHeaders(),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((item) => Weapon.fromJson(item)).toList();
  }

  static Future<Weapon> getWeaponById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/weapons/$id'),
      headers: await ApiService.getHeaders(),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'];
    return Weapon.fromJson(data);
  }

  static Future<Weapon> createWeapon(Map<String, dynamic> weaponData) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/weapons'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode(weaponData),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'];
    return Weapon.fromJson(data);
  }

  static Future<Weapon> updateWeapon(String id, Map<String, dynamic> weaponData) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/weapons/$id'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode(weaponData),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'];
    return Weapon.fromJson(data);
  }

  static Future<void> deleteWeapon(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/weapons/$id'),
      headers: await ApiService.getHeaders(),
    );
    _handleResponseError(response);
  }
}
