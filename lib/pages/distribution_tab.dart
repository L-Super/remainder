import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import '../data/models/account_category.dart';
import '../data/models/category_config.dart';

class DistributionTab extends StatelessWidget {
  final AppStore store;

  const DistributionTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final byCategory = store.accountsByCategory;
    final summary    = store.currentNetWorth;
    final trueReturn = store.trueReturn;

    final items = byCategory.entries.map((e) {
      final cfg   = kCategoryConfig[e.key]!;
      final value = e.value.fold(0.0, (s, a) => s + a.currentAmount);
      return _Item(name: cfg.name, value: value, color: cfg.color,
          isLiability: cfg.isLiabilityDefault || e.key == AccountCategory.debt);
    }).where((d) => d.value > 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('资产分布',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: PieChart(PieChartData(
                  sections: items.map((d) => PieChartSectionData(
                    value: d.value, color: d.color, radius: 35,
                    title: '', showTitle: false,
                  )).toList(),
                  centerSpaceRadius: 55,
                  sectionsSpace: 3,
                )),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.gray50),
              const SizedBox(height: 12),
              ...items.map((d) {
                final pct = summary.totalAssets > 0 ? (d.value / summary.totalAssets) * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(d.name,
                                style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
                          ),
                          Text('${pct.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                          const SizedBox(width: 8),
                          Text(
                            '${d.isLiability ? '-' : ''}${formatAmount(d.value, compact: true)}',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: d.isLiability ? AppColors.error : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 6,
                          backgroundColor: AppColors.gray100,
                          valueColor: AlwaysStoppedAnimation(d.color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (trueReturn.totalInvested > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('投资真实收益',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                const SizedBox(height: 12),
                _Row('累计投入', formatAmount(trueReturn.totalInvested)),
                _Row('当前市值', formatAmount(trueReturn.currentValue)),
                const Divider(height: 24, color: AppColors.gray100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('真实收益',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(
                        '${trueReturn.trueReturn >= 0 ? '+' : ''}${formatAmount(trueReturn.trueReturn)}',
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: trueReturn.trueReturn >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        '${trueReturn.returnRate >= 0 ? '+' : ''}${trueReturn.returnRate.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: trueReturn.returnRate >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Item {
  final String name;
  final double value;
  final Color color;
  final bool isLiability;
  const _Item({required this.name, required this.value, required this.color, required this.isLiability});
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray900)),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
);
