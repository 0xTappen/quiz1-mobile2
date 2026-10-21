import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/add_transaction_modal.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'chat/gemini_chat_screen.dart';
import 'budget/budget_screen.dart';
import 'statistics/statistics_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateToTab: _onTabSelected),
      const TransactionsScreen(),
      GeminiChatScreen(
        isEmbedded: true,
        onNavigateHome: () => _onTabSelected(0),
      ),
      const BudgetScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    // Sembunyikan FAB jika sedang di tab Chat AI agar tidak menutupi input text
    final showFab = _currentIndex != 2;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => AddTransactionModal.show(context),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              tooltip: 'Catat Transaksi',
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
