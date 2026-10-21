import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Cashly';
  static const String appTagline = 'Kelola Keuangan Pribadi dengan Cerdas';
  static const String currencySymbol = 'Rp';

  // Expense Categories
  static const List<String> expenseCategories = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  // Income Categories
  static const List<String> incomeCategories = [
    'Gaji',
    'Investasi',
    'Bonus',
    'Lainnya',
  ];

  // Category Icons
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return Icons.restaurant_rounded;
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Belanja':
        return Icons.shopping_bag_rounded;
      case 'Tagihan':
        return Icons.receipt_long_rounded;
      case 'Hiburan':
        return Icons.movie_filter_rounded;
      case 'Kesehatan':
        return Icons.favorite_rounded;
      case 'Pendidikan':
        return Icons.school_rounded;
      case 'Gaji':
        return Icons.account_balance_wallet_rounded;
      case 'Investasi':
        return Icons.trending_up_rounded;
      case 'Bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
