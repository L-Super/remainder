import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/net_worth_point.dart';

class TrendTab extends StatefulWidget {
  final List<NetWorthPoint> trend;

  const TrendTab({super.key, required this.trend});

  @override
  State<TrendTab> createState() => _TrendTabState();
}

class _TrendTabState extends State<TrendTab> {
  String _period = 'all';

  static const _periods = [
    ('30', '30天'), ('90', '90天'), ('365', '1年'), ('all', '全部'),
  ];

  List<NetWorthPoint> get _filtered {
    if (_period == 'all') return widget.trend;
    final days   = int.parse(_period);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return widget.trend.where((t) => t.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('净资产趋势',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  Row(
                    children: _periods.map(((String key, String label) p) => GestureDetector(
                      onTap: () => setState(() => _period = p.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _period == p.$1 ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p.$2,
                            style: TextStyle(
                              fontSize: 11,
                              color: _period == p.$1 ? Colors.white : AppColors.gray500,
                            )),
                      ),
                    )).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.length >= 2)
                SizedBox(
                  height: 200,
                  child: _buildLineChart(data),
                )
              else
                const SizedBox(height: 60, child: Center(child: Text('数据不足', style: TextStyle(color: AppColors.gray400)))),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.gray50),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Legend(color: AppColors.primaryBlue, label: '净资产', solid: true),
                  const SizedBox(width: 16),
                  _Legend(color: AppColors.success, label: '总资产', solid: false),
                  const SizedBox(width: 16),
                  _Legend(color: AppColors.error, label: '总负债', solid: false),
                ],
              ),
            ],
          ),
        ),
        if (data.any((t) => t.milestone != null)) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('里程碑',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                const SizedBox(height: 12),
                ...data.where((t) => t.milestone != null).map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Text(t.milestone!.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.milestone!.title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF92400E))),
                          Text(DateFormat('yyyy年MM月dd日').format(t.date),
                              style: const TextStyle(fontSize: 12, color: Color(0xFFB45309))),
                        ],
                      ),
                    ),
                    if (t.milestone!.amountImpact != null)
                      Text('+${formatAmount(t.milestone!.amountImpact!, compact: true)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ]),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineChart(List<NetWorthPoint> data) {
    FlSpot toSpot(int i, double y) => FlSpot(i.toDouble(), y);

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((e) => toSpot(e.key, e.value.netWorth)).toList(),
          isCurved: true, color: AppColors.primaryBlue, barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.primaryBlue.withValues(alpha: 0.15), AppColors.primaryBlue.withValues(alpha: 0)],
            ),
          ),
        ),
        LineChartBarData(
          spots: data.asMap().entries.map((e) => toSpot(e.key, e.value.totalAssets)).toList(),
          isCurved: true, color: AppColors.success, barWidth: 1.5,
          dotData: const FlDotData(show: false), dashArray: [4, 2],
        ),
        LineChartBarData(
          spots: data.asMap().entries.map((e) => toSpot(e.key, e.value.totalLiabilities)).toList(),
          isCurved: true, color: AppColors.error, barWidth: 1.5,
          dotData: const FlDotData(show: false), dashArray: [4, 2],
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= data.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(DateFormat('MM/dd').format(data[i].date),
                    style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.gray900,
          getTooltipItems: (spots) {
            final labels = ['净资产', '总资产', '总负债'];
            return spots.asMap().entries.map((e) => LineTooltipItem(
              '${labels[e.key]}: ${formatAmount(e.value.y, compact: true)}',
              const TextStyle(color: Colors.white, fontSize: 11),
            )).toList();
          },
        ),
      ),
    ));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool solid;

  const _Legend({required this.color, required this.label, required this.solid});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 20, height: 2,
        decoration: BoxDecoration(
          color: solid ? color : null,
          borderRadius: BorderRadius.circular(1),
          gradient: solid ? null : LinearGradient(colors: [color, Colors.transparent, color, Colors.transparent]),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
    ]);
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
);
