import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Brand Title Widget displaying "Smart Expense Manager" matching the brand typography & colors.
class BrandLogoTitle extends StatelessWidget {
  const BrandLogoTitle({
    super.key,
    this.fontSize = 28,
    this.spacing = 0,
    this.showSubtitle = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final double fontSize;
  final double spacing;
  final bool showSubtitle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        RichText(
          textAlign: crossAxisAlignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.left,
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.12,
            ),
            children: [
              TextSpan(
                text: 'Smart\n',
                style: TextStyle(
                  color: const Color(0xFF0B132B), // Exact dark navy from logo
                ),
              ),
              TextSpan(
                text: 'Expense\n',
                style: TextStyle(
                  color: const Color(0xFF00A86B), // Exact vivid emerald from logo
                ),
              ),
              TextSpan(
                text: 'Manager',
                style: TextStyle(
                  color: const Color(0xFF0B132B), // Exact dark navy from logo
                ),
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'y e s i t e c h . c o m',
            textAlign: crossAxisAlignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: (fontSize * 0.38).clamp(11.0, 14.0),
              fontWeight: FontWeight.w500,
              letterSpacing: 2.2,
              color: const Color(0xFF94A3B8), // slate-400
            ),
          ),
        ],
      ],
    );
  }
}
