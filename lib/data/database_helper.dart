import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'mock_data.dart';
import 'models/account.dart';
import 'models/account_category.dart';
import 'models/milestone.dart';
import 'models/snapshot.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _db;

  DatabaseHelper._();
  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'remainder.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            institution_name TEXT NOT NULL,
            alias TEXT,
            icon TEXT NOT NULL,
            sub_type TEXT,
            is_liability INTEGER NOT NULL,
            current_amount REAL NOT NULL,
            total_invested REAL,
            currency TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            markets TEXT,
            cash_amount REAL,
            position_amount REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE snapshots (
            id TEXT PRIMARY KEY,
            account_id TEXT NOT NULL,
            amount REAL NOT NULL,
            record_date INTEGER NOT NULL,
            milestone_id TEXT,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE milestones (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date INTEGER NOT NULL,
            amount_impact REAL,
            icon TEXT NOT NULL
          )
        ''');
        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    final b = db.batch();
    for (final m in mockMilestones) {
      b.insert('milestones', _milestoneToMap(m));
    }
    for (final a in initialAccounts) {
      b.insert('accounts', _accountToMap(a));
    }
    for (final s in initialSnapshots) {
      b.insert('snapshots', _snapshotToMap(s));
    }
    await b.commit(noResult: true);
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<List<Account>> loadAccounts() async {
    final db = await _database;
    return (await db.query('accounts')).map(_accountFromMap).toList();
  }

  Future<List<Snapshot>> loadSnapshots() async {
    final db = await _database;
    return (await db.query('snapshots')).map(_snapshotFromMap).toList();
  }

  Future<List<Milestone>> loadMilestones() async {
    final db = await _database;
    return (await db.query('milestones')).map(_milestoneFromMap).toList();
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<void> upsertAccount(Account a) async {
    final db = await _database;
    await db.insert('accounts', _accountToMap(a),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertSnapshot(Snapshot s) async {
    final db = await _database;
    await db.insert('snapshots', _snapshotToMap(s),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> resetToSeed() async {
    final db = await _database;
    final b = db.batch();
    b.delete('accounts');
    b.delete('snapshots');
    for (final a in initialAccounts) b.insert('accounts', _accountToMap(a));
    for (final s in initialSnapshots) b.insert('snapshots', _snapshotToMap(s));
    await b.commit(noResult: true);
  }

  // ── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> _accountToMap(Account a) => {
        'id': a.id,
        'category': a.category.name,
        'institution_name': a.institutionName,
        'alias': a.alias,
        'icon': a.icon,
        'sub_type': a.subType?.name,
        'is_liability': a.isLiability ? 1 : 0,
        'current_amount': a.currentAmount,
        'total_invested': a.totalInvested,
        'currency': a.currency,
        'status': a.status.name,
        'created_at': a.createdAt.millisecondsSinceEpoch,
        'markets': a.markets?.map((m) => m.name).join(','),
        'cash_amount': a.cashAmount,
        'position_amount': a.positionAmount,
      };

  Account _accountFromMap(Map<String, dynamic> row) {
    final marketsStr = row['markets'] as String?;
    return Account(
      id: row['id'] as String,
      category: AccountCategory.values.byName(row['category'] as String),
      institutionName: row['institution_name'] as String,
      alias: row['alias'] as String?,
      icon: row['icon'] as String,
      subType: row['sub_type'] != null
          ? AccountSubType.values.byName(row['sub_type'] as String)
          : null,
      isLiability: (row['is_liability'] as int) == 1,
      currentAmount: (row['current_amount'] as num).toDouble(),
      totalInvested: row['total_invested'] != null ? (row['total_invested'] as num).toDouble() : null,
      currency: row['currency'] as String,
      status: AccountStatus.values.byName(row['status'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      markets: marketsStr?.split(',').map((s) => MarketType.values.byName(s)).toList(),
      cashAmount: row['cash_amount'] != null ? (row['cash_amount'] as num).toDouble() : null,
      positionAmount: row['position_amount'] != null ? (row['position_amount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> _snapshotToMap(Snapshot s) => {
        'id': s.id,
        'account_id': s.accountId,
        'amount': s.amount,
        'record_date': s.recordDate.millisecondsSinceEpoch,
        'milestone_id': s.milestoneId,
        'note': s.note,
      };

  Snapshot _snapshotFromMap(Map<String, dynamic> row) => Snapshot(
        id: row['id'] as String,
        accountId: row['account_id'] as String,
        amount: (row['amount'] as num).toDouble(),
        recordDate:
            DateTime.fromMillisecondsSinceEpoch(row['record_date'] as int),
        milestoneId: row['milestone_id'] as String?,
        note: row['note'] as String?,
      );

  Map<String, dynamic> _milestoneToMap(Milestone m) => {
        'id': m.id,
        'title': m.title,
        'date': m.date.millisecondsSinceEpoch,
        'amount_impact': m.amountImpact,
        'icon': m.icon,
      };

  Milestone _milestoneFromMap(Map<String, dynamic> row) => Milestone(
        id: row['id'] as String,
        title: row['title'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
        amountImpact: row['amount_impact'] != null ? (row['amount_impact'] as num).toDouble() : null,
        icon: row['icon'] as String,
      );
}
