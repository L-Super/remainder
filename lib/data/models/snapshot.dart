class Snapshot {
  final String id;
  final String accountId;
  final double amount;
  final DateTime recordDate;
  final String? note;
  final String? milestoneId;

  const Snapshot({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.recordDate,
    this.note,
    this.milestoneId,
  });

  Snapshot copyWith({double? amount, String? note}) => Snapshot(
        id: id,
        accountId: accountId,
        amount: amount ?? this.amount,
        recordDate: recordDate,
        note: note ?? this.note,
        milestoneId: milestoneId,
      );
}
