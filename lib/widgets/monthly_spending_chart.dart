import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/transaction_model.dart';

class MonthlySpendingChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const MonthlySpendingChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group last 7 days of expenses
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final Map<int, double> dailyTotals = {};
    for (int i = 0; i < 7; i++) {
      dailyTotals[i] = 0.0;
    }

    for (final tx in transactions.where((t) => t.isExpense)) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      for (int i = 0; i < 7; i++) {
        if (txDate.isAtSameMomentAs(last7Days[i])) {
          dailyTotals[i] = (dailyTotals[i] ?? 0) + tx.amount;
          break;
        }
      }
    }

    double maxY = 0;
    for (final val in dailyTotals.values) {
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 100000;
    // Add 20% headroom
    maxY = maxY * 1.25;

    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tren Pengeluaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '7 Hari Terakhir',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Mingguan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        CurrencyFormatter.formatCompact(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= 7) return const SizedBox();
                        final date = last7Days[idx];
                        final dayName = dayNames[date.weekday % 7];
                        final isToday = idx == 6;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dayName,
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                ),
                barGroups: List.generate(7, (i) {
                  final amount = dailyTotals[i] ?? 0.0;
                  final isToday = i == 6;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: isToday ? AppColors.accent : AppColors.primary,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
