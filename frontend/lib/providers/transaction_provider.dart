import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _history = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Transaction> get history => _history;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _history = await TransactionService.getHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchaseItem(String weaponId, int quantity, {required Function() onSuccess}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final tx = await TransactionService.purchaseItem(weaponId, quantity);
      _history.insert(0, tx);
      onSuccess();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
