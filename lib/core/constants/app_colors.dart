import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF1E56A0); // Deep Persian Sapphire
  static const Color primaryLight = Color(0xFFD6E4F0);
  static const Color primaryDark = Color(0xFF163172);

  // Status & Financial Indicators
  static const Color freeBalanceSafe = Color(0xFF00897B); // Emerald Green
  static const Color freeBalanceSafeBg = Color(0xFFE0F2F1);
  static const Color freeBalanceWarning = Color(0xFFF57C00); // Amber Orange
  static const Color freeBalanceWarningBg = Color(0xFFFFF3E0);
  static const Color freeBalanceDanger = Color(0xFFD32F2F); // Crimson Red
  static const Color freeBalanceDangerBg = Color(0xFFFFEBEE);

  static const Color income = Color(0xFF2E7D32); // Forest Green
  static const Color expense = Color(0xFFC62828); // Dark Red
  static const Color commitment = Color(0xFFE65100); // Deep Orange

  // Backgrounds & Surfaces (Light)
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Backgrounds & Surfaces (Dark)
  static const Color surfaceDark = Color(0xFF121418);
  static const Color cardDark = Color(0xFF1E222B);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Bank Brand Colors
  static const Map<String, Color> bankColors = {
    'ملت': Color(0xFFC62828),
    'ملی': Color(0xFF1565C0),
    'تجارت': Color(0xFF00838F),
    'صادرات': Color(0xFF283593),
    'پاسارگاد': Color(0xFFF57F17),
    'سامان': Color(0xFF0097A7),
    'بلو': Color(0xFF2979FF),
    'رسالت': Color(0xFF2E7D32),
    'سپه': Color(0xFF37474F),
    'شهر': Color(0xFFAD1457),
    'کشاورزی': Color(0xFF388E3C),
    'پارسیان': Color(0xFF7B1FA2),
  };
}
