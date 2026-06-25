import 'package:intl/intl.dart';

String formatAmount(double value, {bool compact = false}) {
  if (compact) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 10000) return '$sign¥${(abs / 10000).toStringAsFixed(1)}万';
    return '$sign¥${abs.toStringAsFixed(0)}';
  }
  final formatter = NumberFormat('#,##0.00', 'zh_CN');
  return '¥${formatter.format(value.abs())}';
}

String formatDate(DateTime date) => DateFormat('yyyy年MM月dd日').format(date);

String formatDateShort(DateTime date) => DateFormat('MM/dd').format(date);

String formatMonth(DateTime date) => DateFormat('MM月').format(date);

String formatChangeRate(double rate) {
  final sign = rate >= 0 ? '+' : '';
  return '$sign${rate.toStringAsFixed(2)}%';
}
