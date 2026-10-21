import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Beranda',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Transaksi',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                label: 'AI Chat',
                isAi: true,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.pie_chart_outline_rounded,
                activeIcon: Icons.pie_chart_rounded,
                label: 'Anggaran',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Statistik',
              ),
              _buildNavItem(
                index: 5,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isAi = false,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAi
                  ? const Color(0xFF4285F4).withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isAi && isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF4285F4),
                        Color(0xFF9B72CF),
                        Color(0xFFD96570),
                      ],
                    ).createShader(bounds),
                    child: Icon(
                      activeIcon,
                      size: 22,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: isSelected
                        ? (isAi ? const Color(0xFF4285F4) : AppColors.primary)
                        : (isAi
                            ? const Color(0xFF9B72CF)
                            : AppColors.textMuted),
                  ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isAi ? const Color(0xFF4285F4) : AppColors.primary)
                    : (isAi
                        ? const Color(0xFF9B72CF)
                        : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
