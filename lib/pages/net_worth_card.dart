import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_types.dart';
import 'home_metric_view.dart';

const _kTabs = [
  (key: MetricView.netWorth,         label: '净资产'),
  (key: MetricView.totalAssets,      label: '总资产'),
  (key: MetricView.totalLiabilities, label: '总负债'),
];

class NetWorthCard extends StatelessWidget {
  final NetWorthSummary summary;
  final NetWorthChange change;
  final MetricView metricView;
  final ValueChanged<MetricView> onMetricChanged;

  const NetWorthCard({
    super.key,
    required this.summary,
    required this.change,
    required this.metricView,
    required this.onMetricChanged,
  });

  double get _display => switch (metricView) {
    MetricView.netWorth         => summary.netWorth,
    MetricView.totalAssets      => summary.totalAssets,
    MetricView.totalLiabilities => summary.totalLiabilities,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: _kTabs.map((tab) => Expanded(
              child: GestureDetector(
                onTap: () => onMetricChanged(tab.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: metricView == tab.key
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: metricView == tab.key
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            _kTabs.firstWhere((t) => t.key == metricView).label,
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 4),
          Text(
            '${metricView == MetricView.totalLiabilities ? '-' : ''}${formatAmount(_display)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (metricView == MetricView.netWorth) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(
                    change.isPositive ? Icons.trending_up : Icons.trending_down,
                    color: change.isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '较上次 ${change.isPositive ? '+' : '-'}${formatAmount(change.amount.abs(), compact: true)}',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (change.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${change.isPositive ? '+' : ''}${change.rate.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: change.isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Row(children: [
                Expanded(child: _BreakdownItem(label: '总资产', value: formatAmount(summary.totalAssets, compact: true))),
                Expanded(child: _BreakdownItem(
                  label: '总负债',
                  value: formatAmount(summary.totalLiabilities, compact: true),
                  valueColor: const Color(0xFFF87171),
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _BreakdownItem({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
