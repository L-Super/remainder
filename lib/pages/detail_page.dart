import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import 'trend_tab.dart';
import 'distribution_tab.dart';
import 'statistics_tab.dart';
import 'history_tab.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _tabIndex = 0;

  static const _tabs = ['趋势', '分布', '统计', '历史'];

  @override
  Widget build(BuildContext context) {
    final store   = context.watch<AppStore>();
    final summary = store.currentNetWorth;
    final change  = store.netWorthChange;
    final trend   = store.netWorthTrend;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('详情分析',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  const SizedBox(height: 2),
                  const Text('财富追踪与深度分析',
                      style: TextStyle(fontSize: 12, color: AppColors.gray400)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _SummaryItem(label: '净资产', value: formatAmount(summary.netWorth, compact: true)),
                            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15)),
                            _SummaryItem(label: '总资产', value: formatAmount(summary.totalAssets, compact: true)),
                            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15)),
                            _SummaryItem(
                              label: '总负债',
                              value: formatAmount(summary.totalLiabilities, compact: true),
                              valueColor: const Color(0xFFF87171),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('较上次变化',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                              Text(
                                '${change.isPositive ? '+' : ''}${formatAmount(change.amount, compact: true)} '
                                '(${change.isPositive ? '+' : ''}${change.rate.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: change.isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _tabIndex == i ? AppColors.primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _tabs[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _tabIndex == i ? Colors.white : AppColors.gray500,
                              ),
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  TrendTab(trend: trend),
                  DistributionTab(store: store),
                  StatisticsTab(store: store),
                  SingleChildScrollView(child: HistoryTab(trend: trend)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
      ]),
    );
  }
}
