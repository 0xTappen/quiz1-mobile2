import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/monthly_spending_chart.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/transaction_detail_modal.dart';
import '../../widgets/add_transaction_modal.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final finance = FinanceScope.of(context);
    final profile = finance.profile;
    final recentTxs = finance.recentTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            finance.loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${profile.name.split(' ').first} 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Kelola keuanganmu dengan bijak hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Gemini AI Chat Button
                        GestureDetector(
                          onTap: () => onNavigateToTab(2),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4285F4),
                                  Color(0xFF9B72CF),
                                  Color(0xFFD96570),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9B72CF)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () => onNavigateToTab(4), // Go to profile tab
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: (profile.avatarUrl != null &&
                                      profile.avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      profile.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(
                                          profile.initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        profile.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Prominent Balance Card
                BalanceCard(
                  totalBalance: finance.totalBalance,
                  monthlyIncome: finance.monthlyIncome,
                  monthlyExpense: finance.monthlyExpense,
                  onAddTransaction: () => AddTransactionModal.show(context),
                ),
                const SizedBox(height: 18),

                // Two Summary Cards: Tabungan Bulan Ini & Sisa Anggaran
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Tabungan Bulan Ini',
                        value: CurrencyFormatter.format(finance.monthlySavings),
                        icon: Icons.savings_outlined,
                        iconColor: AppColors.accent,
                        iconBgColor: AppColors.accent.withValues(alpha: 0.12),
                        subtitle: finance.monthlySavings >= 0
                            ? 'Kondisi surplus'
                            : 'Kondisi defisit',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Sisa Anggaran',
                        value: CurrencyFormatter.format(
                          finance.remainingBudget,
                        ),
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                        subtitle:
                            '${(finance.budgetProgress * 100).toStringAsFixed(0)}% terpakai',
                        onTap: () => onNavigateToTab(2), // Go to budget tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gemini AI Card Banner
                GestureDetector(
                  onTap: () => onNavigateToTab(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF4285F4),
                                Color(0xFF9B72CF),
                                Color(0xFFD96570),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFF9B72CF),
                                        Color(0xFFD96570),
                                      ],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Gemini AI',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0FE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Chatbot',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF1967D2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Tanya tips hemat & analisis keuanganmu di sini.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Weekly Spending Chart
                MonthlySpendingChart(transactions: finance.transactions),
                const SizedBox(height: 22),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          onNavigateToTab(1), // Go to transactions tab
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Recent Transactions List
                if (recentTxs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum Ada Transaksi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mulai catat pemasukan dan pengeluaranmu',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentTxs.map((tx) {
                    return TransactionTile(
                      transaction: tx,
                      onTap: () => TransactionDetailModal.show(context, tx),
                    );
                  }),
                const SizedBox(height: 80), // Bottom padding for FAB & nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
