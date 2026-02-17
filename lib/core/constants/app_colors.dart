import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Vibrant Green Theme
  static const Color primary = Color(0xFF53E88B); // Vibrant Green
  static const Color primaryDark = Color(0xFF15BE77); // Darker Green
  static const Color primaryLight = Color(0xFF7EF3A7); // Lighter Green

  // Secondary Colors
  static const Color secondary = Color(0xFF12D18E); // Accent Green
  static const Color secondaryDark = Color(0xFF0FA877);
  static const Color secondaryLight = Color(0xFF3EE0A5);

  // Background Colors - Clean White
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color cardBackground = Color(0xFFFFFFFF); // White Cards
  static const Color premiumBackground = Color(0xFFFAFAFA); // Premium Off-White

  // Text Colors - Black & Gray
  static const Color textPrimary = Color(0xFF09051C); // Almost Black
  static const Color textSecondary = Color(0xFF9A9FA5); // Gray
  static const Color textHint = Color(0xFFB3B3B3); // Light Gray
  static const Color textLight = Color(0xFF6B6E82); // Medium Gray

  // Status Colors
  static const Color success = Color(0xFF53E88B); // Green (same as primary)
  static const Color warning = Color(0xFFFEAD1D); // Yellow/Orange
  static const Color error = Color(0xFFF54748); // Red
  static const Color info = Color(0xFF3C92FF); // Blue

  // Category Accent Colors - Premium & Vibrant
  static const Color accentFood = Color(0xFFFF7C32); // Vibrant Orange
  static const Color accentMarket = Color(
    0xFF53E88B,
  ); // Vibrant Green (Primary)
  static const Color accentHealth = Color(0xFF3C92FF); // Blue
  static const Color accentBakery = Color(0xFFA16B47); // Brown/Gold
  static const Color accentCoffee = Color(0xFF6F4E37); // Coffee Brown
  static const Color accentFlowers = Color(0xFFFF69B4); // Pink

  // Category Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF53E88B), Color(0xFF15BE77)],
  );

  static const LinearGradient gradientOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9F67), Color(0xFFFF7C32)],
  );

  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6FB1FF), Color(0xFF3C92FF)],
  );

  // Background Colors for accented items (Subtle)
  static Color getAccentBackground(Color accentColor) =>
      accentColor.withOpacity(0.08);

  // Border Colors - Light Gray
  static const Color border = Color(0xFFF4F4F4); // Very Light Gray
  static const Color borderDark = Color(0xFFE8E8E8); // Light Gray

  // Shadow Colors
  static const Color shadow = Color(0x0F000000); // Light shadow
  static const Color shadowMedium = Color(0x1A000000); // Medium shadow

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // Dark overlay
  static const Color overlayLight = Color(0x40000000); // Light overlay

  // Promo/Special Colors
  static const Color promoGreen = Color(0xFF53E88B); // For promo banners
  static const Color promoBackground = Color(
    0xFFF0FFF4,
  ); // Light green background
}
