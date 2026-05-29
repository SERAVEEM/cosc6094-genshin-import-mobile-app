import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
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

  static Future<List<Transaction>> getHistory() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/transactions/history'),
      headers: await ApiService.getHeaders(),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((item) => Transaction.fromJson(item)).toList();
  }

  static Future<Transaction> purchaseItem(String weaponId, int quantity) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/transactions'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'weapon_id': weaponId,
        'quantity': quantity,
      }),
    );
    _handleResponseError(response);
    final data = jsonDecode(response.body)['data'];
    return Transaction.fromJson(data);
  }
}
