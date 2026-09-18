import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Reusable Brand Title Widget displaying "moby money" with the exact 2-tone colors from the logo.
class BrandLogoTitle extends StatelessWidget {
  const BrandLogoTitle({
    super.key,
    this.fontSize = 28,
    this.spacing = 0,
  });

  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'moby',
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.brandDark,
            ),
          ),
          if (spacing > 0)
            WidgetSpan(
              child: SizedBox(width: spacing),
            ),
          TextSpan(
            text: 'money',
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.brandTeal,
            ),
          ),
        ],
      ),
    );
  }
}
