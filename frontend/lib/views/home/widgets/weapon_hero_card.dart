import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/weapon.dart';

class WeaponHeroCard extends StatelessWidget {
  final Weapon weapon;
  final VoidCallback onTap;

  const WeaponHeroCard({
    super.key,
    required this.weapon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.cardBg,
          image: DecorationImage(
            image: (weapon.image.startsWith('http')
                ? NetworkImage(weapon.image)
                : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}')) as ImageProvider,
            fit: BoxFit.cover,
            onError: (err, stack) {
              // fallback handled by Stack containing fallback gradients
            },
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.space4),
                      color: Colors.black.withOpacity(0.35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weapon.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.space2),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space4,
                                  vertical: AppTheme.space2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Get',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.space1),
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
