class Milestone {
  final String id;
  final String title;
  final DateTime date;
  final double? amountImpact;
  final String icon;

  const Milestone({
    required this.id,
    required this.title,
    required this.date,
    this.amountImpact,
    required this.icon,
  });
}
