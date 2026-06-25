import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/net_worth_point.dart';

class HistoryTab extends StatelessWidget {
  final List<NetWorthPoint> trend;

  const HistoryTab({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    final reversed = trend.reversed.toList();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Text('历史快照记录',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            ),
            const Divider(height: 1, color: AppColors.gray50),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reversed.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.gray50),
              itemBuilder: (_, i) => _HistoryItem(point: reversed[i]),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final NetWorthPoint point;

  const _HistoryItem({required this.point});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.gray400),
              const SizedBox(width: 6),
              Text(DateFormat('yyyy年MM月dd日').format(point.date),
                  style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
              if (point.milestone != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${point.milestone!.icon} ${point.milestone!.title}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                ),
              ],
              const Spacer(),
              Text(formatAmount(point.netWorth, compact: true),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('总资产', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                  const SizedBox(height: 2),
                  Text(formatAmount(point.totalAssets, compact: true),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray700)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('总负债', style: TextStyle(fontSize: 11, color: Color(0xFFFB7185))),
                  const SizedBox(height: 2),
                  Text(formatAmount(point.totalLiabilities, compact: true),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
                ]),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
