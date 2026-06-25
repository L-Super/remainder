import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(outlined: Icons.home_outlined,       filled: Icons.home,       label: '首页'),
    _NavItemData(outlined: Icons.pie_chart_outline,   filled: Icons.pie_chart,  label: '分析'),
    _NavItemData(outlined: Icons.assignment_outlined, filled: Icons.assignment, label: '账户'),
    _NavItemData(outlined: Icons.settings_outlined,   filled: Icons.settings,   label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) => _NavItem(
              data: _items[i],
              isActive: currentIndex == i,
              onTap: () => onTap(i),
            )),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData outlined;
  final IconData filled;
  final String label;
  const _NavItemData({required this.outlined, required this.filled, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.data, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? data.filled : data.outlined,
                size: 22,
                color: isActive ? AppColors.primaryBlue : AppColors.gray400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primaryBlue : AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
