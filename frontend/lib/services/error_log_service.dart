import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorLog {
  final String id;
  final String timestamp;
  final String message;

  ErrorLog({
    required this.id,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'message': message,
      };

  factory ErrorLog.fromJson(Map<String, dynamic> json) => ErrorLog(
        id: json['id'] as String,
        timestamp: json['timestamp'] as String,
        message: json['message'] as String,
      );
}

class ErrorLogService {
  static const String _key = 'error_logs';

  static Future<void> logError(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_key) ?? [];
      
      final newLog = ErrorLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp: DateTime.now().toLocal().toString().split('.').first,
        message: message,
      );
      
      logsJson.add(jsonEncode(newLog.toJson()));
      
      // Limit list size to 100 to avoid storage bloat
      if (logsJson.length > 100) {
        logsJson.removeAt(0);
      }
      
      await prefs.setStringList(_key, logsJson);
    } catch (e) {
      // Fallback print if storage write fails
      debugPrint('Fallback error logging: $message (write error: $e)');
    }
  }

  static Future<List<ErrorLog>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_key) ?? [];
      return logsJson
          .map((item) => ErrorLog.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList()
          .reversed
          .toList(); // Return newest first
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
