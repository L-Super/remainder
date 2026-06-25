import 'milestone.dart';

class NetWorthPoint {
  final DateTime date;
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final Milestone? milestone;

  const NetWorthPoint({
    required this.date,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    this.milestone,
  });
}
