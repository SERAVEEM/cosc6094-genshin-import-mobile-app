import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/error_log_service.dart';

class ErrorDialog {
  static void show(BuildContext context, String message) {
    // Log error to persistent storage
    ErrorLogService.logError(message);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.accent),
            ),
          ),
        ],
      ),
    );
  }
}
