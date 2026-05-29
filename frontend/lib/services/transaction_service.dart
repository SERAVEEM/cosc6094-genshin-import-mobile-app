import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import 'weapon_service.dart';

class TransactionService {
  static Future<List<Transaction>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve mock transactions
    final txsStr = prefs.getString('mock_transactions') ?? '[]';
    final List<dynamic> list = jsonDecode(txsStr);
    
    // Sort transactions by date descending (newest first)
    list.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
    
    return list.map((item) => Transaction.fromJson(item)).toList();
  }

  static String _generateRedeemCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    String segment(int seedOffset) {
      final buffer = StringBuffer();
      for (int i = 0; i < 4; i++) {
        final index = (random + seedOffset + i * 7) % chars.length;
        buffer.write(chars[index]);
      }
      return buffer.toString();
    }
    return 'GS-${segment(100)}-${segment(200)}-${segment(300)}';
  }

  static Future<Transaction> purchaseItem(String weaponId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();

    // Check if user is logged in
    final userStr = prefs.getString('auth_user');
    if (userStr == null) {
      throw Exception('Unauthorized! Please log in to complete purchase.');
    }
    final user = User.fromJson(jsonDecode(userStr));

    // Get weapon detail and check stock
    final weapon = await WeaponService.getWeaponById(weaponId);
    if (weapon.stock < quantity) {
      throw Exception('Stok tidak mencukupi!');
    }

    // Deduct stock in mock database
    await WeaponService.updateWeapon(weaponId, {
      'stock': weapon.stock - quantity,
    });

    final totalPrice = weapon.price * quantity;
    final String redeemCode = _generateRedeemCode();
    final newTxMap = {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': user.id,
      'weapon_id': weaponId,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'weapon_name': weapon.name,
      'weapon_type': weapon.type,
      'weapon_image': weapon.image,
      'redeem_code': redeemCode,
    };

    final txsStr = prefs.getString('mock_transactions') ?? '[]';
    final List<dynamic> txsJson = jsonDecode(txsStr);
    txsJson.add(newTxMap);
    await prefs.setString('mock_transactions', jsonEncode(txsJson));

    return Transaction.fromJson(newTxMap);
  }
}
