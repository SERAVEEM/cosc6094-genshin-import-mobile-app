import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/weapon.dart';
import '../../shared/get_button.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weapon.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffd9d9d9).withOpacity(0.85),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 0), // <-- Adjust left/right margins here
                  child: GetButton(),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0), // <-- Adjust margins for the whole price row here
                  child: Row(
                    children: [
                      Image.asset(
                        'asset/Icon/Primo icons.png',
                        width: 16, // <-- Primo Icon Width
                        height: 16, // <-- Primo Icon Height
                      ),
                      const SizedBox(width: 4), // <-- Spacing between icon and price text
                      Text(
                        weapon.price.toStringAsFixed(0),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14, // <-- Price font size
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
