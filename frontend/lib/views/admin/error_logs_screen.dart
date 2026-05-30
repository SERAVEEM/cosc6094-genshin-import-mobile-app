import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/error_log_service.dart';

class ErrorLogsScreen extends StatefulWidget {
  const ErrorLogsScreen({super.key});

  @override
  State<ErrorLogsScreen> createState() => _ErrorLogsScreenState();
}

class _ErrorLogsScreenState extends State<ErrorLogsScreen> {
  List<ErrorLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });
    final logs = await ErrorLogService.getLogs();
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Clear All Logs', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus semua catatan log error di perangkat ini?', style: TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('CLEAR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ErrorLogService.clearLogs();
      _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua log error berhasil dihapus!')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesan error disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Error Logs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: _clearLogs,
              tooltip: 'Clear All Logs',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        color: AppTheme.accent,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : _logs.isEmpty
                ? Stack(
                    children: [
                      ListView(), // Necessary for RefreshIndicator to work
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppTheme.accent,
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Sistem Berjalan Normal',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada log error yang tersimpan.',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (ctx, index) {
                      final log = _logs[index];
                      return Card(
                        color: AppTheme.cardBg,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        log.timestamp,
                                        style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      color: AppTheme.textMuted,
                                      size: 18,
                                    ),
                                    onPressed: () => _copyToClipboard(log.message),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Copy Error Message',
                                  ),
                                ],
                              ),
                              const Divider(color: AppTheme.borderSubtle, height: 20),
                              Text(
                                log.message,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
