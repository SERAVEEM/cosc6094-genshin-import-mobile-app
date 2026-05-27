import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  static Future<Transaction> purchaseItem(String weaponId, int quantity) async {
    final url = Uri.parse('${ApiService.baseUrl}/transactions');
    final response = await http.post(
      url,
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'weapon_id': weaponId,
        'quantity': quantity,
      }),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Transaksi pembelian gagal!');
    }
    
    return Transaction.fromJson(data['data']);
  }

  static Future<List<Transaction>> getHistory() async {
    final url = Uri.parse('${ApiService.baseUrl}/transactions/history');
    final response = await http.get(url, headers: await ApiService.getHeaders());
    
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal memuat riwayat transaksi!');
    }
    
    final List<dynamic> list = data['data'];
    return list.map((item) => Transaction.fromJson(item)).toList();
  }
}
