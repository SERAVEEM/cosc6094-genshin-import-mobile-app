import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weapon.dart';
import 'api_service.dart';

class WeaponService {
  static Future<List<Weapon>> getCatalog() async {
    final url = Uri.parse('${ApiService.baseUrl}/weapons');
    final response = await http.get(url, headers: await ApiService.getHeaders());
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memuat katalog!');
    }
    
    final List<dynamic> list = data['data'];
    return list.map((item) => Weapon.fromJson(item)).toList();
  }

  static Future<Weapon> getWeaponById(String id) async {
    final url = Uri.parse('${ApiService.baseUrl}/weapons/$id');
    final response = await http.get(url, headers: await ApiService.getHeaders());
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Produk tidak ditemukan!');
    }
    
    return Weapon.fromJson(data['data']);
  }

  static Future<Weapon> createWeapon(Map<String, dynamic> weaponData) async {
    final url = Uri.parse('${ApiService.baseUrl}/weapons');
    final response = await http.post(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode(weaponData),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal menambahkan produk!');
    }
    
    return Weapon.fromJson(data['data']);
  }

  static Future<Weapon> updateWeapon(String id, Map<String, dynamic> weaponData) async {
    final url = Uri.parse('${ApiService.baseUrl}/weapons/$id');
    final response = await http.put(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode(weaponData),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memperbarui produk!');
    }
    
    return Weapon.fromJson(data['data']);
  }

  static Future<void> deleteWeapon(String id) async {
    final url = Uri.parse('${ApiService.baseUrl}/weapons/$id');
    final response = await http.delete(url, headers: await ApiService.getHeaders());
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal menghapus produk!');
    }
  }
}
