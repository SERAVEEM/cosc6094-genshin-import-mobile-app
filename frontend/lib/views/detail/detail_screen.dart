import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/weapon.dart';
import '../../providers/weapon_provider.dart';
import '../../providers/transaction_provider.dart';
import '../shared/error_dialog.dart';

class WeaponDetailScreen extends StatefulWidget {
  final String weaponId;

  const WeaponDetailScreen({
    super.key,
    required this.weaponId,
  });

  @override
  State<WeaponDetailScreen> createState() => _WeaponDetailScreenState();
}

class _WeaponDetailScreenState extends State<WeaponDetailScreen> {
  int _quantity = 1;
  bool _isPurchasing = false;

  void _increment(int maxStock) {
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _buy(Weapon weapon) async {
    setState(() {
      _isPurchasing = true;
    });

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final weaponProvider = Provider.of<WeaponProvider>(context, listen: false);

    try {
      await txProvider.purchaseItem(
        weapon.id,
        _quantity,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembelian sukses!')),
          );
          weaponProvider.fetchCatalog();
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weaponProvider = Provider.of<WeaponProvider>(context);
    
    final weaponIndex = weaponProvider.rawWeapons.indexWhere((w) => w.id == widget.weaponId);
    if (weaponIndex == -1) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final weapon = weaponProvider.rawWeapons[weaponIndex];
    final bool isOutOfStock = weapon.stock <= 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Product Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                image: DecorationImage(
                  image: weapon.image.startsWith('http')
                      ? NetworkImage(weapon.image)
                      : AssetImage('assets/images/${weapon.image}') as ImageProvider,
                  fit: BoxFit.cover,
                  onError: (err, stack) {},
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          weapon.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space3,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          weapon.type,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Row(
                    children: [
                      Icon(
                        isOutOfStock ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                        color: isOutOfStock ? Colors.redAccent : Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOutOfStock 
                            ? 'Out of Stock' 
                            : 'In Stock (${weapon.stock} items left)',
                        style: TextStyle(
                          color: isOutOfStock ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space6),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space2),
                  Text(
                    weapon.description.isNotEmpty 
                        ? weapon.description 
                        : 'No description provided.',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price per Item',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.diamond_rounded,
                                color: Colors.lightBlueAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                weapon.price.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!isOutOfStock)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.accent),
                              onPressed: _decrement,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.accent),
                              onPressed: () => _increment(weapon.stock),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),
                  _isPurchasing
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isOutOfStock ? null : () => _buy(weapon),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: AppTheme.cardBg,
                              disabledForegroundColor: AppTheme.textMuted,
                              padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isOutOfStock ? 'OUT OF STOCK' : 'PURCHASE NOW',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
