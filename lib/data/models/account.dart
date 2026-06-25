import 'account_category.dart';

enum AccountSubType { savings, credit }

enum MarketType { a, hk, us }

enum AccountStatus { active, archived }

class Account {
  final String id;
  final AccountCategory category;
  final String institutionName;
  final String? alias;
  final String icon;
  final AccountSubType? subType;
  final bool isLiability;
  final double currentAmount;
  final double? totalInvested;
  final String currency;
  final AccountStatus status;
  final DateTime createdAt;
  final List<MarketType>? markets;
  final double? cashAmount;
  final double? positionAmount;

  const Account({
    required this.id,
    required this.category,
    required this.institutionName,
    this.alias,
    required this.icon,
    this.subType,
    required this.isLiability,
    required this.currentAmount,
    this.totalInvested,
    this.currency = 'CNY',
    this.status = AccountStatus.active,
    required this.createdAt,
    this.markets,
    this.cashAmount,
    this.positionAmount,
  });

  Account copyWith({
    double? currentAmount,
    AccountStatus? status,
  }) =>
      Account(
        id: id,
        category: category,
        institutionName: institutionName,
        alias: alias,
        icon: icon,
        subType: subType,
        isLiability: isLiability,
        currentAmount: currentAmount ?? this.currentAmount,
        totalInvested: totalInvested,
        currency: currency,
        status: status ?? this.status,
        createdAt: createdAt,
        markets: markets,
        cashAmount: cashAmount,
        positionAmount: positionAmount,
      );
}
