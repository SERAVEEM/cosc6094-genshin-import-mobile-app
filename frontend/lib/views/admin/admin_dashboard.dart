import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/weapon_provider.dart';
import 'weapon_form.dart';
import 'error_logs_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final weaponProvider = Provider.of<WeaponProvider>(context);
    final list = weaponProvider.rawWeapons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: Colors.redAccent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ErrorLogsScreen()),
              );
            },
            tooltip: 'View Error Logs',
          ),
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: AppTheme.accent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeaponFormScreen()),
              );
            },
            tooltip: 'Add New Product',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => weaponProvider.fetchCatalog(),
        color: AppTheme.accent,
        child: weaponProvider.isLoading && list.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
            : list.isEmpty
                ? const Center(
                    child: Text('Katalog kosong! Silakan tambahkan produk baru.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: list.length,
                    itemBuilder: (ctx, idx) {
                      final weapon = list[idx];
                      return Card(
                        color: AppTheme.cardBg,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: (weapon.image.startsWith('http')
                                    ? NetworkImage(weapon.image)
                                    : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}')) as ImageProvider,
                                fit: BoxFit.cover,
                                onError: (err, stack) {},
                              ),
                            ),
                          ),
                          title: Text(
                            weapon.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${weapon.type}  •  Stock: ${weapon.stock}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Price: ${weapon.price.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => WeaponFormScreen(weapon: weapon),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(context, weaponProvider, weapon.id),
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

  void _confirmDelete(BuildContext context, WeaponProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Delete Product', style: TextStyle(color: Colors.redAccent)),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini dari katalog aktif?', style: TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await provider.deleteWeapon(id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil dinonaktifkan!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
