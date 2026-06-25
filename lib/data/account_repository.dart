import 'database_helper.dart';
import 'models/account.dart';
import 'models/milestone.dart';
import 'models/snapshot.dart';

class AccountRepository {
  final _db = DatabaseHelper();

  Future<List<Account>>   loadAccounts()   => _db.loadAccounts();
  Future<List<Snapshot>>  loadSnapshots()  => _db.loadSnapshots();
  Future<List<Milestone>> loadMilestones() => _db.loadMilestones();

  Future<void> upsertAccount(Account a)   => _db.upsertAccount(a);
  Future<void> upsertSnapshot(Snapshot s) => _db.upsertSnapshot(s);
  Future<void> resetToSeed()              => _db.resetToSeed();
}
