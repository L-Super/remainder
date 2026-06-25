import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import '../data/models/net_worth_point.dart';

class StatisticsTab extends StatelessWidget {
  final AppStore store;

  const StatisticsTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final stats      = store.statistics;
    final trend      = store.netWorthTrend;
    final trueReturn = store.trueReturn;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              icon: Icons.trending_up,
              label: '历史最高',
              value: formatAmount(stats.max, compact: true),
              sub: DateFormat('MM/dd').format(stats.maxDate),
              gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
            ),
            _StatCard(
              icon: Icons.trending_down,
              label: '历史最低',
              value: formatAmount(stats.min, compact: true),
              sub: DateFormat('MM/dd').format(stats.minDate),
              gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            _StatCard(
              icon: Icons.show_chart,
              label: '平均月增长',
              value: '${stats.avgMonthlyGrowth.toStringAsFixed(2)}%',
              sub: '几何平均',
              gradientColors: const [AppColors.primaryBlue, AppColors.primaryBlueDark],
            ),
            _StatCard(
              icon: Icons.history,
              label: '快照记录',
              value: '${stats.totalSnapshots}条',
              sub: '全部历史',
              gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (trend.length >= 2) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('月度净资产变化',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                const SizedBox(height: 16),
                SizedBox(height: 160, child: _buildBarChart(trend)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (trueReturn.totalInvested > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('投资收益拆分',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                const SizedBox(height: 12),
                _Row('股票+基金 累计投入', formatAmount(trueReturn.totalInvested)),
                _Row('当前市值', formatAmount(trueReturn.currentValue)),
                const Divider(height: 20, color: AppColors.gray100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('市值收益',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                    Text(
                      '${trueReturn.trueReturn >= 0 ? '+' : ''}${formatAmount(trueReturn.trueReturn)}',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: trueReturn.trueReturn >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '真实收益 = 当前市值 − 累计投入，剔除存入部分，仅反映市场回报。',
                  style: TextStyle(fontSize: 12, color: AppColors.gray400),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBarChart(List<NetWorthPoint> trend) {
    final bars = <({String label, double delta})>[];
    for (int i = 1; i < trend.length; i++) {
      bars.add((
        label: DateFormat('MM月').format(trend[i].date),
        delta: trend[i].netWorth - trend[i - 1].netWorth,
      ));
    }

    return BarChart(BarChartData(
      barGroups: bars.asMap().entries.map((e) => BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(
          toY: e.value.delta,
          color: e.value.delta >= 0 ? AppColors.primaryBlue : AppColors.error,
          width: 20,
          borderRadius: e.value.delta >= 0
              ? const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))
              : const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
        )],
      )).toList(),
      titlesData: FlTitlesData(
        leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, reservedSize: 20,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= bars.length) return const SizedBox.shrink();
              return Text(bars[i].label,
                  style: const TextStyle(fontSize: 10, color: AppColors.gray400));
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.gray900,
          getTooltipItem: (group, _, rod, __) => BarTooltipItem(
            formatAmount(rod.toY, compact: true),
            const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final List<Color> gradientColors;

  const _StatCard({
    required this.icon, required this.label,
    required this.value, required this.sub,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradientColors.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
          ]),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
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
