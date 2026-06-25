import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import '../data/models/account.dart';
import '../data/models/account_category.dart';
import '../data/models/category_config.dart';

class AccountListCard extends StatefulWidget {
  final AppStore store;

  const AccountListCard({super.key, required this.store});

  @override
  State<AccountListCard> createState() => _AccountListCardState();
}

class _AccountListCardState extends State<AccountListCard> {
  final Set<AccountCategory> _expanded = {AccountCategory.bank};

  static const _order = [
    AccountCategory.bank, AccountCategory.stock, AccountCategory.fund,
    AccountCategory.property, AccountCategory.insurance, AccountCategory.debt, AccountCategory.custom,
  ];

  @override
  Widget build(BuildContext context) {
    final byCategory = widget.store.accountsByCategory;

    return Container(
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
              child: Text('账户明细',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.gray50),
            ..._order.map((cat) {
              final accounts = byCategory[cat];
              if (accounts == null || accounts.isEmpty) return const SizedBox.shrink();
              return _CategorySection(
                category: cat,
                accounts: accounts,
                isExpanded: _expanded.contains(cat),
                onToggle: () => setState(() {
                  _expanded.contains(cat) ? _expanded.remove(cat) : _expanded.add(cat);
                }),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final AccountCategory category;
  final List<Account> accounts;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CategorySection({
    required this.category,
    required this.accounts,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cfg      = kCategoryConfig[category]!;
    final catTotal = accounts.fold(0.0, (s, a) => s + a.currentAmount);
    final isDebt   = category == AccountCategory.debt;

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(cfg.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cfg.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray900)),
                      Text('${accounts.length}个账户',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                    ],
                  ),
                ),
                Text(
                  '${isDebt ? '-' : ''}${formatAmount(catTotal, compact: true)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDebt ? AppColors.error : AppColors.gray900,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.25 : 0,
                  child: const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ColoredBox(
            color: const Color(0xFFFAFAFA),
            child: Column(
              children: accounts.map((acc) => Padding(
                padding: const EdgeInsets.fromLTRB(34, 10, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: cfg.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc.institutionName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
                          if (acc.alias != null)
                            Text(acc.alias!,
                                style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${acc.isLiability ? '-' : ''}${formatAmount(acc.currentAmount, compact: true)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: acc.isLiability ? AppColors.error : AppColors.gray900,
                          ),
                        ),
                        if (acc.subType == AccountSubType.credit)
                          const Text('欠款',
                              style: TextStyle(fontSize: 11, color: AppColors.error)),
                        if (acc.totalInvested != null) ...[
                          Text(
                            '${acc.currentAmount >= acc.totalInvested! ? '+' : ''}${formatAmount(acc.currentAmount - acc.totalInvested!, compact: true)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: acc.currentAmount >= acc.totalInvested!
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.gray50),
      ],
    );
  }
}
