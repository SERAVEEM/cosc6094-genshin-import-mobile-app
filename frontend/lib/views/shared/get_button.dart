import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double fontSize;

  const GetButton({
    super.key,
    this.onTap,
    this.width = 64,
    this.height = 28,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Detail specifications (defaults are slightly larger):
    // 1. Font -> Plus Jakarta Sans, Bold, Size: default 10, Color: #f8f8f8f8
    // 2. Box Size -> default 54x20, Fill: #656565 20%
    // 3. Box Effect -> Refraction 80, Depth 20, Dispersion 50, Frost 4, Splay 0
    //
    // Translation of effects to Flutter:
    // - Frost: 4 -> ImageFilter.blur(sigmaX: 4, sigmaY: 4)
    // - Fill: #656565 20% -> Color(0xff656565).withOpacity(0.20)
    // - Refraction: 80 -> Translucent border highlight (Color(0xccffffff) or withOpacity(0.80))
    // - Depth: 20 -> Subtle shadow/offset to create layers (depth effect)
    // - Dispersion: 50 -> Blur radius of the shadows / light-bleed
    // - Splay: 0 -> Spread radius of 0
    
    final Widget buttonBody = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.80), // Refraction: 80
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20), // Depth: 20
            blurRadius: 5.0, // Dispersion: 50
            spreadRadius: 0.0, // Splay: 0
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // Frost: 4
          child: Container(
            color: const Color(0xff656565).withOpacity(0.20), // Fill: #656565 20%
            alignment: Alignment.center,
            child: Text(
              'Get',
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xf8f8f8f8), // Font Color: #f8f8f8f8
                height: 1.0,
                letterSpacing: 0,
              ),
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
