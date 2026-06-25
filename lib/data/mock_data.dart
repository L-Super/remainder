import 'models/account.dart';
import 'models/account_category.dart';
import 'models/milestone.dart';
import 'models/snapshot.dart';

final List<Milestone> mockMilestones = [
  Milestone(id: 'ms-1', title: '季度奖金', date: DateTime(2026, 3, 15), amountImpact: 15000, icon: '🎉'),
  Milestone(id: 'ms-2', title: '股票盈利', date: DateTime(2026, 5, 15), amountImpact: 8000,  icon: '📈'),
];

final List<Account> initialAccounts = [
  Account(id: 'acc-1', category: AccountCategory.bank,  institutionName: '招商银行', alias: '工资卡',  icon: '🏦', subType: AccountSubType.savings, isLiability: false, currentAmount: 45000, createdAt: DateTime(2026, 2, 1)),
  Account(id: 'acc-2', category: AccountCategory.bank,  institutionName: '工商银行', alias: '备用卡',  icon: '🏦', subType: AccountSubType.savings, isLiability: false, currentAmount: 30000, createdAt: DateTime(2026, 2, 1)),
  Account(id: 'acc-3', category: AccountCategory.bank,  institutionName: '招商银行', alias: '信用卡',  icon: '💳', subType: AccountSubType.credit,  isLiability: true,  currentAmount: 6500,  createdAt: DateTime(2026, 2, 1)),
  Account(id: 'acc-4', category: AccountCategory.stock, institutionName: '华泰证券', alias: 'A股账户', icon: '📈', isLiability: false, currentAmount: 38000, totalInvested: 30000, createdAt: DateTime(2026, 2, 1), markets: [MarketType.a], cashAmount: 5000, positionAmount: 33000),
  Account(id: 'acc-5', category: AccountCategory.stock, institutionName: '富途证券', alias: '美股账户', icon: '📈', isLiability: false, currentAmount: 15000, totalInvested: 18000, createdAt: DateTime(2026, 2, 1), markets: [MarketType.us]),
  Account(id: 'acc-6', category: AccountCategory.fund,  institutionName: '天天基金', alias: '指数基金', icon: '💰', isLiability: false, currentAmount: 22000, totalInvested: 20000, createdAt: DateTime(2026, 2, 1)),
  Account(id: 'acc-7', category: AccountCategory.fund,  institutionName: '支付宝',   alias: '货币基金', icon: '💰', isLiability: false, currentAmount: 11000, totalInvested: 10500, createdAt: DateTime(2026, 2, 1)),
];

final List<Snapshot> initialSnapshots = [
  // Feb 2026
  Snapshot(id: 's1',  accountId: 'acc-1', amount: 40000, recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's2',  accountId: 'acc-2', amount: 30000, recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's3',  accountId: 'acc-3', amount: 5000,  recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's4',  accountId: 'acc-4', amount: 28000, recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's5',  accountId: 'acc-5', amount: 16000, recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's6',  accountId: 'acc-6', amount: 18000, recordDate: DateTime(2026, 2, 15)),
  Snapshot(id: 's7',  accountId: 'acc-7', amount: 8000,  recordDate: DateTime(2026, 2, 15)),
  // Mar 2026
  Snapshot(id: 's8',  accountId: 'acc-1', amount: 43000, recordDate: DateTime(2026, 3, 15), milestoneId: 'ms-1'),
  Snapshot(id: 's9',  accountId: 'acc-2', amount: 30000, recordDate: DateTime(2026, 3, 15)),
  Snapshot(id: 's10', accountId: 'acc-3', amount: 6000,  recordDate: DateTime(2026, 3, 15)),
  Snapshot(id: 's11', accountId: 'acc-4', amount: 35000, recordDate: DateTime(2026, 3, 15)),
  Snapshot(id: 's12', accountId: 'acc-5', amount: 15000, recordDate: DateTime(2026, 3, 15)),
  Snapshot(id: 's13', accountId: 'acc-6', amount: 20000, recordDate: DateTime(2026, 3, 15)),
  Snapshot(id: 's14', accountId: 'acc-7', amount: 9000,  recordDate: DateTime(2026, 3, 15)),
  // Apr 2026
  Snapshot(id: 's15', accountId: 'acc-1', amount: 45000, recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's16', accountId: 'acc-2', amount: 30000, recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's17', accountId: 'acc-3', amount: 7000,  recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's18', accountId: 'acc-4', amount: 32000, recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's19', accountId: 'acc-5', amount: 17000, recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's20', accountId: 'acc-6', amount: 21000, recordDate: DateTime(2026, 4, 15)),
  Snapshot(id: 's21', accountId: 'acc-7', amount: 10000, recordDate: DateTime(2026, 4, 15)),
  // May 2026
  Snapshot(id: 's22', accountId: 'acc-1', amount: 47000, recordDate: DateTime(2026, 5, 15)),
  Snapshot(id: 's23', accountId: 'acc-2', amount: 30000, recordDate: DateTime(2026, 5, 15)),
  Snapshot(id: 's24', accountId: 'acc-3', amount: 8000,  recordDate: DateTime(2026, 5, 15)),
  Snapshot(id: 's25', accountId: 'acc-4', amount: 38000, recordDate: DateTime(2026, 5, 15), milestoneId: 'ms-2'),
  Snapshot(id: 's26', accountId: 'acc-5', amount: 14000, recordDate: DateTime(2026, 5, 15)),
  Snapshot(id: 's27', accountId: 'acc-6', amount: 22000, recordDate: DateTime(2026, 5, 15)),
  Snapshot(id: 's28', accountId: 'acc-7', amount: 11000, recordDate: DateTime(2026, 5, 15)),
  // Jun 2026
  Snapshot(id: 's29', accountId: 'acc-1', amount: 45000, recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's30', accountId: 'acc-2', amount: 30000, recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's31', accountId: 'acc-3', amount: 6500,  recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's32', accountId: 'acc-4', amount: 38000, recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's33', accountId: 'acc-5', amount: 15000, recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's34', accountId: 'acc-6', amount: 22000, recordDate: DateTime(2026, 6, 15)),
  Snapshot(id: 's35', accountId: 'acc-7', amount: 11000, recordDate: DateTime(2026, 6, 15)),
];
