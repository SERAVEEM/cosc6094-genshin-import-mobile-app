import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/weapon.dart';
import '../../shared/get_button.dart';

class TrendingItemTile extends StatelessWidget {
  final Weapon weapon;
  final VoidCallback onTap;

  const TrendingItemTile({
    super.key,
    required this.weapon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.space3),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.cardBg,
                image: DecorationImage(
                  image: (weapon.image.startsWith('http')
                      ? NetworkImage(weapon.image)
                      : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}')) as ImageProvider,
                  fit: BoxFit.cover,
                  onError: (err, stack) {},
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weapon.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weapon.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const GetButton(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(
                      'asset/Icon/Primo icons.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weapon.price.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
