import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetButton extends StatelessWidget {
  final VoidCallback? onTap;

  const GetButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Detail specifications:
    // 1. Font -> Plus Jakarta Sans, Bold, Size: 8, Color: #f8f8f8f8
    // 2. Box Size -> 42x16, Fill: #656565 20%
    // 3. Box Effect -> Refraction 80, Depth 20, Dispersion 50, Frost 4, Splay 0
    //
    // Translation of effects to Flutter:
    // - Frost: 4 -> ImageFilter.blur(sigmaX: 4, sigmaY: 4)
    // - Fill: #656565 20% -> Color(0xff656565).withOpacity(0.20)
    // - Refraction: 80 -> Translucent border highlight (Color(0xccffffff) or withOpacity(0.80))
    // - Depth: 20 -> Subtle shadow/offset to create layers (depth effect)
    // - Dispersion: 50 -> Blur radius of the shadows / light-bleed
    // - Splay: 0 -> Spread radius of 0
    
    final Widget buttonBody = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // Frost: 4
        child: Container(
          width: 42,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xff656565).withOpacity(0.20), // Fill: #656565 20%
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.80), // Refraction: 80 (80% opacity)
              width: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20), // Depth: 20 (20% opacity shadow)
                blurRadius: 5.0, // Dispersion: 50 (blur radius 5.0)
                spreadRadius: 0.0, // Splay: 0
                offset: const Offset(0, 1.5), // Depth offset
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'GET',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: const Color(0xf8f8f8f8), // Font Color: #f8f8f8f8
              height: 1.0,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: buttonBody,
        ),
      );
    }

    return buttonBody;
  }
}
