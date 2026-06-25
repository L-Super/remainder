import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import '../data/models/account_category.dart';
import '../data/models/category_config.dart';

class DistributionCard extends StatelessWidget {
  final AppStore store;

  const DistributionCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final byCategory = store.accountsByCategory;
    final summary    = store.currentNetWorth;

    final items = byCategory.entries
        .where((e) => e.key != AccountCategory.debt)
        .map((e) {
          final cfg   = kCategoryConfig[e.key]!;
          final value = e.value.fold(0.0, (s, a) => s + a.currentAmount);
          return _Item(name: cfg.name, value: value, color: cfg.color);
        })
        .where((d) => d.value > 0)
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('资产构成',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(PieChartData(
                  sections: items.map((d) => PieChartSectionData(
                    value: d.value,
                    color: d.color,
                    radius: 19,
                    title: '',
                    showTitle: false,
                  )).toList(),
                  centerSpaceRadius: 36,
                  sectionsSpace: 2,
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ...items.map((d) => _LegendRow(
                      color: d.color,
                      label: d.name,
                      value: formatAmount(d.value, compact: true),
                    )),
                    if (summary.totalLiabilities > 0)
                      _LegendRow(
                        color: AppColors.error,
                        label: '负债',
                        value: '-${formatAmount(summary.totalLiabilities, compact: true)}',
                        valueColor: AppColors.error,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String name;
  final double value;
  final Color color;
  const _Item({required this.name, required this.value, required this.color});
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final Color? valueColor;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ]),
          Text(value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.gray900,
              )),
        ],
      ),
    );
  }
}
