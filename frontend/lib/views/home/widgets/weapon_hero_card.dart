import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/weapon.dart';
import '../../shared/get_button.dart';
import 'package:google_fonts/google_fonts.dart';

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
          image: const DecorationImage(
            image: AssetImage('assets/Product/Top items.png'),
            fit: BoxFit.cover,
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
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: AppTheme.space6,
                          right: AppTheme.space4,
                          top: AppTheme.space4,
                          bottom: AppTheme.space4,
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0x00d9d9d9), // 0% #d9d9d9 0% opacity
                              Color(0x4d000000), // 100% #000000 30% opacity
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weapon.name.replaceFirst(' ', '\n'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700, 
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
                                const Padding(
                                  padding: EdgeInsets.only(right: 1.0),
                                  child: GetButton(),
                                ),
                                const SizedBox(height: AppTheme.space1),
                                Padding(
                                  padding: const EdgeInsets.only(right: 7.0), // <-- Adjust margins for the whole price row here
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'asset/Icon/Primo icons.png',
                                        width: 16, // <-- Primo Icon Width
                                        height: 16, // <-- Primo Icon Height
                                      ),
                                      const SizedBox(width: 2), // <-- Spacing between icon and price text
                                      Text(
                                        weapon.price.toStringAsFixed(0),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16, // <-- Price font size
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
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 8,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.25),
                                  Colors.transparent,
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
            ],
          ),
        ),
      ),
    );
  }
}
