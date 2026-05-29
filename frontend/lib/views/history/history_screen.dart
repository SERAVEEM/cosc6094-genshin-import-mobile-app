import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/transaction_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<TransactionProvider>(context, listen: false).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => txProvider.fetchHistory(),
        color: AppTheme.accent,
        child: txProvider.isLoading && txProvider.history.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : txProvider.history.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: txProvider.history.length,
                    itemBuilder: (ctx, idx) {
                      final tx = txProvider.history[idx];
                      
                      String dateStr = tx.createdAt;
                      try {
                        final parsed = DateTime.parse(tx.createdAt).toLocal();
                        dateStr = "${parsed.day}/${parsed.month}/${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
                      } catch (_) {}

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppTheme.cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              image: tx.weaponImage != null
                                  ? DecorationImage(
                                      image: (tx.weaponImage!.startsWith('http')
                                          ? NetworkImage(tx.weaponImage!)
                                          : AssetImage(tx.weaponImage!.startsWith('assets/') ? tx.weaponImage! : 'assets/images/${tx.weaponImage!}')) as ImageProvider,
                                      fit: BoxFit.cover,
                                      onError: (err, stack) {},
                                    )
                                  : null,
                            ),
                            child: tx.weaponImage == null
                                ? const Icon(Icons.shield_moon_outlined, color: AppTheme.accent)
                                : null,
                          ),
                          title: Text(
                            tx.weaponName ?? 'Unknown Weapon',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${tx.quantity}  •  $dateStr',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              if (tx.redeemCode != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 0.8),
                                      ),
                                      child: Text(
                                        tx.redeemCode!,
                                        style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: tx.redeemCode!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Redeem code copied!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.copy_rounded,
                                        color: AppTheme.accent,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Paid',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'asset/Icon/Primo icons.png',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tx.totalPrice.toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
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
