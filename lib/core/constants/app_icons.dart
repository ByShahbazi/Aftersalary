import 'package:flutter/material.dart';

class AppIcons {
  /// نگاشت کدهای آیکون به آیکون‌های استاندارد متریال برای حفظ قابلیت Font Tree Shaking
  static IconData getCategoryIcon(int? iconCode) {
    if (iconCode == null) return Icons.category_outlined;

    switch (iconCode) {
      case 0xe532:
        return Icons.restaurant;
      case 0xe318:
        return Icons.home;
      case 0xe1d5:
        return Icons.directions_car;
      case 0xef49:
        return Icons.account_balance;
      case 0xef64:
        return Icons.receipt_long;
      case 0xe3eb:
        return Icons.local_hospital;
      case 0xf37d:
      case 0xe59c:
        return Icons.shopping_bag;
      case 0xe3b1:
        return Icons.local_cafe;
      case 0xe548:
        return Icons.school;
      case 0xe3ae:
        return Icons.more_horiz;
      case 0xe481:
        return Icons.payments;
      case 0xe6e8:
        return Icons.card_giftcard;
      case 0xe627:
        return Icons.trending_up;
      case 0xe047:
        return Icons.add_circle;
      default:
        return Icons.category_outlined;
    }
  }
}
