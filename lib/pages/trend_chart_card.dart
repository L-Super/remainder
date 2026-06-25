import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/net_worth_point.dart';
import 'home_metric_view.dart';

class TrendChartCard extends StatelessWidget {
  final List<NetWorthPoint> trend;
  final MetricView metricView;
  final VoidCallback? onViewDetail;

  const TrendChartCard({
    super.key,
    required this.trend,
    required this.metricView,
    this.onViewDetail,
  });

  List<FlSpot> _toSpots() => trend.asMap().entries.map((e) {
    final y = switch (metricView) {
      MetricView.netWorth         => e.value.netWorth,
      MetricView.totalAssets      => e.value.totalAssets,
      MetricView.totalLiabilities => e.value.totalLiabilities,
    };
    return FlSpot(e.key.toDouble(), y);
  }).toList();

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();
    final spots = _toSpots();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('趋势',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
              GestureDetector(
                onTap: onViewDetail,
                child: const Row(
                  children: [
                    Text('查看详情',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                    Icon(Icons.chevron_right, size: 14, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: LineChart(LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primaryBlue,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.18),
                        AppColors.primaryBlue.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('MM/dd').format(trend[i].date),
                          style: const TextStyle(fontSize: 10, color: AppColors.gray400),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.gray900,
                  getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                    formatAmount(s.y, compact: true),
                    const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  )).toList(),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
