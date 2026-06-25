import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/app_store.dart';
import 'home_metric_view.dart';
import 'net_worth_card.dart';
import 'trend_chart_card.dart';
import 'distribution_card.dart';
import 'account_list_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToDetail;
  final VoidCallback? onNavigateToRecord;

  const HomePage({super.key, this.onNavigateToDetail, this.onNavigateToRecord});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MetricView _metricView = MetricView.netWorth;

  @override
  Widget build(BuildContext context) {
    final store   = context.watch<AppStore>();
    final summary = store.currentNetWorth;
    final change  = store.netWorthChange;
    final trend   = store.netWorthTrend;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
              children: [
                NetWorthCard(
                  summary: summary,
                  change: change,
                  metricView: _metricView,
                  onMetricChanged: (v) => setState(() => _metricView = v),
                ),
                const SizedBox(height: 16),
                TrendChartCard(
                  trend: trend,
                  metricView: _metricView,
                  onViewDetail: widget.onNavigateToDetail,
                ),
                const SizedBox(height: 16),
                DistributionCard(store: store),
                const SizedBox(height: 16),
                AccountListCard(store: store),
                const SizedBox(height: 16),
                Text(
                  '最近更新 · ${DateFormat('yyyy年MM月dd日').format(DateTime.now())}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray400),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 16,
              child: GestureDetector(
                onTap: widget.onNavigateToRecord,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueDark,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('更新',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
