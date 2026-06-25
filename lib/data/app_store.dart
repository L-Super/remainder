import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'app_types.dart';
import 'account_repository.dart';
import 'mock_data.dart';
import 'models/account.dart';
import 'models/account_category.dart';
import 'models/category_config.dart';
import 'models/milestone.dart';
import 'models/net_worth_point.dart';
import 'models/snapshot.dart';

class AppStore extends ChangeNotifier {
  final _repo = AccountRepository();

  List<Account>   _accounts  = [];
  List<Snapshot>  _snapshots = [];
  List<Milestone> milestones = [];

  List<Account>  get accounts  => List.unmodifiable(_accounts);
  List<Snapshot> get snapshots => List.unmodifiable(_snapshots);

  Future<void> init() async {
    _accounts  = await _repo.loadAccounts();
    _snapshots = await _repo.loadSnapshots();
    milestones = await _repo.loadMilestones();
    notifyListeners();
  }

  // ─── Computed ───────────────────────────────────────────────────────────────

  NetWorthSummary get currentNetWorth {
    final active = _accounts.where((a) => a.status == AccountStatus.active);
    final assets = active.where((a) => !a.isLiability).fold(0.0, (s, a) => s + a.currentAmount);
    final liabilities = active.where((a) => a.isLiability).fold(0.0, (s, a) => s + a.currentAmount);
    return (netWorth: assets - liabilities, totalAssets: assets, totalLiabilities: liabilities);
  }

  List<NetWorthPoint> get netWorthTrend {
    final dates = _snapshots.map((s) => _dayKey(s.recordDate)).toSet().toList()..sort();
    return dates.map((dateKey) {
      final daySnaps = _snapshots.where((s) => _dayKey(s.recordDate) == dateKey).toList();
      double assets = 0, liabilities = 0;
      for (final snap in daySnaps) {
        final acc = _accounts.firstWhereOrNull((a) => a.id == snap.accountId);
        if (acc == null || acc.status != AccountStatus.active) continue;
        if (acc.isLiability) { liabilities += snap.amount; } else { assets += snap.amount; }
      }
      final msSnap = daySnaps.firstWhereOrNull((s) => s.milestoneId != null);
      final milestone = msSnap != null
          ? milestones.firstWhereOrNull((m) => m.id == msSnap.milestoneId)
          : null;
      final parts = dateKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return NetWorthPoint(
        date: date,
        netWorth: assets - liabilities,
        totalAssets: assets,
        totalLiabilities: liabilities,
        milestone: milestone,
      );
    }).toList();
  }

  NetWorthChange get netWorthChange {
    final trend = netWorthTrend;
    if (trend.length < 2) return (amount: 0.0, rate: 0.0, isPositive: true);
    final current  = trend.last.netWorth;
    final previous = trend[trend.length - 2].netWorth;
    final amount   = current - previous;
    final rate     = previous != 0 ? (amount / previous) * 100 : 0.0;
    return (amount: amount, rate: rate, isPositive: amount >= 0);
  }

  Map<AccountCategory, List<Account>> get accountsByCategory {
    final result = <AccountCategory, List<Account>>{};
    for (final cat in kCategoryOrder) {
      final group = _accounts.where((a) => a.category == cat && a.status == AccountStatus.active).toList();
      if (group.isNotEmpty) result[cat] = group;
    }
    return result;
  }

  ({double totalInvested, double currentValue, double trueReturn, double returnRate}) get trueReturn {
    final investable = _accounts.where((a) =>
        (a.category == AccountCategory.stock || a.category == AccountCategory.fund) &&
        a.totalInvested != null &&
        a.status == AccountStatus.active);
    final totalInvested = investable.fold(0.0, (s, a) => s + a.totalInvested!);
    final currentValue  = investable.fold(0.0, (s, a) => s + a.currentAmount);
    final tr = currentValue - totalInvested;
    final returnRate = totalInvested > 0 ? (tr / totalInvested) * 100 : 0.0;
    return (totalInvested: totalInvested, currentValue: currentValue, trueReturn: tr, returnRate: returnRate);
  }

  ({double max, DateTime maxDate, double min, DateTime minDate, double avgMonthlyGrowth, int totalSnapshots}) get statistics {
    final trend = netWorthTrend;
    if (trend.isEmpty) {
      return (max: 0.0, maxDate: DateTime.now(), min: 0.0, minDate: DateTime.now(), avgMonthlyGrowth: 0.0, totalSnapshots: 0);
    }
    final amounts = trend.map((t) => t.netWorth).toList();
    final maxVal  = amounts.reduce(math.max);
    final minVal  = amounts.reduce(math.min);
    final maxDate = trend[amounts.indexOf(maxVal)].date;
    final minDate = trend[amounts.indexOf(minVal)].date;
    final first  = amounts.first;
    final last   = amounts.last;
    final months = amounts.length - 1;
    final avgMonthlyGrowth = (months > 0 && first > 0)
        ? (math.pow(last / first, 1.0 / months).toDouble() - 1) * 100
        : 0.0;
    return (
      max: maxVal,
      maxDate: maxDate,
      min: minVal,
      minDate: minDate,
      avgMonthlyGrowth: avgMonthlyGrowth,
      totalSnapshots: _snapshots.length,
    );
  }

  // ─── Mutations ──────────────────────────────────────────────────────────────

  void updateAccount(String accountId, double amount, DateTime date, {String? note}) {
    final updated = _accounts.firstWhere((a) => a.id == accountId).copyWith(currentAmount: amount);
    _accounts = _accounts.map((a) => a.id == accountId ? updated : a).toList();

    final key = _dayKey(date);
    final existing = _snapshots.firstWhereOrNull(
      (s) => s.accountId == accountId && _dayKey(s.recordDate) == key,
    );

    final Snapshot snap;
    if (existing != null) {
      snap = existing.copyWith(amount: amount, note: note);
      _snapshots = _snapshots.map((s) => s.id == existing.id ? snap : s).toList();
    } else {
      snap = Snapshot(
        id: 's-${DateTime.now().millisecondsSinceEpoch}-$accountId',
        accountId: accountId,
        amount: amount,
        recordDate: DateTime(date.year, date.month, date.day),
        note: note,
      );
      _snapshots = [..._snapshots, snap];
    }

    notifyListeners();
    _repo.upsertAccount(updated);
    _repo.upsertSnapshot(snap);
  }

  void addAccount(Account account) {
    final snap = Snapshot(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      accountId: account.id,
      amount: account.currentAmount,
      recordDate: DateTime.now(),
    );
    _accounts  = [..._accounts, account];
    _snapshots = [..._snapshots, snap];
    notifyListeners();
    _repo.upsertAccount(account);
    _repo.upsertSnapshot(snap);
  }

  void reset() {
    _accounts  = List.of(initialAccounts);
    _snapshots = List.of(initialSnapshots);
    notifyListeners();
    _repo.resetToSeed();
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

extension _IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
