import 'package:flutter/material.dart';

class AppColors {
  // Nature Theme - Greens & Earth Tones
  static const Color forestGreen = Color(0xFF2D5016);
  static const Color leafGreen = Color(0xFF4A7C59);
  static const Color mintGreen = Color(0xFF52B788);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color earthBrown = Color(0xFF8D5524);
  static const Color warmOrange = Color(0xFFE9724C);
  static const Color sunsetOrange = Color(0xFFD65108);
  static const Color deepRed = Color(0xFF9D0208);

  // Background Colors - Nature themed
  static const Color darkBackground = Color(0xFF1A2416); // Dark forest
  static const Color cardBackground = Color(0xFF263B1F); // Forest floor
  static const Color surfaceColor = Color(0xFF34492D); // Moss green

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6EC);
  static const Color textSecondary = Color(0xFFB5C9A8);
  static const Color textTertiary = Color(0xFF7A9268);

  // Accent Colors - Nature themed
  static const Color success = Color(0xFF52B788); // Fresh green
  static const Color warning = Color(0xFFE9C46A); // Golden yellow
  static const Color danger = Color(0xFFDA3633);
  static const Color info = Color(0xFF74C69D); // Aqua green

  // Primary accent
  static const Color primary = Color(0xFF52B788); // Vibrant green
  static const Color primaryLight = Color(0xFF74C69D);

  // Backward compatible aliases
  static const Color cyan = primary; // Map to main green
  static const Color coolBlue = leafGreen;
  static const Color yellow = Color(0xFFE9C46A);
  static const Color orange = warmOrange;
  static const Color red = sunsetOrange;
  static const Color darkRed = deepRed;
  static const Color deepBlue =
      Color(0xFF1B4332); // Deep forest green as replacement

  static const Color secondary = warmOrange; // Added secondary alias

  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33A8D5BA); // Light green tint

  // Heat Scale (for map visualization) - Cool greens to hot reds
  static List<Color> heatScale = [
    Color(0xFF1B4332), // Deep forest
    leafGreen, // Leaf green
    mintGreen, // Mint
    lightGreen, // Light green
    Color(0xFFE9C46A), // Golden
    warmOrange, // Warm orange
    sunsetOrange, // Sunset
    deepRed, // Deep red
  ];

  // Get color based on temperature (normalized 0-1)
  static Color getHeatColor(double normalizedTemp) {
    if (normalizedTemp <= 0.0) return heatScale[0];
    if (normalizedTemp >= 1.0) return heatScale.last;

    final index = (normalizedTemp * (heatScale.length - 1)).floor();
    final nextIndex = (index + 1).clamp(0, heatScale.length - 1);
    final fraction = (normalizedTemp * (heatScale.length - 1)) - index;

    return Color.lerp(heatScale[index], heatScale[nextIndex], fraction)!;
  }

  // Gradient combinations for nature theme
  static const LinearGradient forestGradient = LinearGradient(
    colors: [forestGreen, leafGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [mintGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
