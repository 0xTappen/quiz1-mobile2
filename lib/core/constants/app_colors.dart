import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1E293B); // Deep Navy
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);

  // Accent
  static const Color accent = Color(0xFF10B981); // Soft Emerald
  static const Color accentLight = Color(0xFFD1FAE5);
  static const Color accentDark = Color(0xFF059669);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Functional Status
  static const Color income = Color(0xFF10B981); // Emerald
  static const Color incomeLight = Color(0xFFECFDF5);
  static const Color expense = Color(0xFFEF4444); // Red
  static const Color expenseLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFEFF6FF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Makanan & Minuman': Color(0xFFF97316), // Orange
    'Transportasi': Color(0xFF0EA5E9), // Light Blue
    'Belanja': Color(0xFFEC4899), // Pink
    'Tagihan': Color(0xFFEAB308), // Yellow
    'Hiburan': Color(0xFF8B5CF6), // Purple
    'Kesehatan': Color(0xFF14B8A6), // Teal
    'Pendidikan': Color(0xFF6366F1), // Indigo
    'Gaji': Color(0xFF10B981), // Emerald
    'Investasi': Color(0xFF06B6D4), // Cyan
    'Bonus': Color(0xFF84CC16), // Lime
    'Lainnya': Color(0xFF64748B), // Slate
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? const Color(0xFF64748B);
  }
}
