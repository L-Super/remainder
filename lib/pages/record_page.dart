import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/app_store.dart';
import '../data/models/account.dart';
import '../data/models/account_category.dart';
import '../data/models/category_config.dart';

enum _View { list, addStep1, addStep2, addStep3 }

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  _View _view = _View.list;
  AccountCategory? _selectedCategory;

  final _institutionCtrl = TextEditingController();
  final _aliasCtrl       = TextEditingController();
  final _amountCtrl      = TextEditingController();
  final _investedCtrl    = TextEditingController();
  AccountSubType _subType = AccountSubType.savings;
  final Set<MarketType> _markets = {MarketType.a};

  final _updateAmountCtrl = TextEditingController();
  final _updateNoteCtrl   = TextEditingController();

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _aliasCtrl.dispose();
    _amountCtrl.dispose();
    _investedCtrl.dispose();
    _updateAmountCtrl.dispose();
    _updateNoteCtrl.dispose();
    super.dispose();
  }

  void _resetAdd() {
    _institutionCtrl.clear();
    _aliasCtrl.clear();
    _amountCtrl.clear();
    _investedCtrl.clear();
    _subType = AccountSubType.savings;
    _markets
      ..clear()
      ..add(MarketType.a);
    setState(() {
      _selectedCategory = null;
      _view = _View.list;
    });
  }

  void _showUpdateSheet(Account account) {
    _updateAmountCtrl.text = account.currentAmount.toStringAsFixed(0);
    _updateNoteCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UpdateSheet(
        account: account,
        amountCtrl: _updateAmountCtrl,
        noteCtrl: _updateNoteCtrl,
        onSave: () {
          final amount = double.tryParse(_updateAmountCtrl.text);
          if (amount == null) return;
          context.read<AppStore>().updateAccount(
            account.id, amount, DateTime.now(),
            note: _updateNoteCtrl.text.isEmpty ? null : _updateNoteCtrl.text,
          );
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已更新 ${account.institutionName}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _submitAdd() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || _selectedCategory == null) return;
    final cfg = kCategoryConfig[_selectedCategory!]!;

    final account = Account(
      id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory!,
      institutionName: _institutionCtrl.text.isEmpty ? cfg.name : _institutionCtrl.text,
      alias: _aliasCtrl.text.isEmpty ? null : _aliasCtrl.text,
      icon: cfg.icon,
      subType: _selectedCategory == AccountCategory.bank ? _subType : null,
      isLiability: cfg.isLiabilityDefault,
      currentAmount: amount,
      totalInvested: (_selectedCategory == AccountCategory.stock ||
              _selectedCategory == AccountCategory.fund) &&
              _investedCtrl.text.isNotEmpty
          ? double.tryParse(_investedCtrl.text)
          : null,
      markets: _selectedCategory == AccountCategory.stock ? _markets.toList() : null,
      createdAt: DateTime.now(),
    );
    context.read<AppStore>().addAccount(account);
    _resetAdd();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已添加 ${account.institutionName}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return switch (_view) {
      _View.list     => _buildList(),
      _View.addStep1 => _buildAddStep1(),
      _View.addStep2 => _buildAddStep2(),
      _View.addStep3 => _buildAddStep3(),
    };
  }

  Widget _buildList() {
    final store      = context.watch<AppStore>();
    final byCategory = store.accountsByCategory;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
          children: [
            const Text('账户管理',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            const SizedBox(height: 2),
            Text('最后更新 · ${DateFormat('yyyy年MM月dd日').format(DateTime.now())}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
            const SizedBox(height: 20),
            ...AccountCategory.values.map((cat) {
              final accounts = byCategory[cat];
              if (accounts == null || accounts.isEmpty) return const SizedBox.shrink();
              final cfg = kCategoryConfig[cat]!;
              return _CategoryGroup(
                cfg: cfg,
                accounts: accounts,
                onAccountTap: _showUpdateSheet,
              );
            }),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => setState(() => _view = _View.addStep1),
            backgroundColor: AppColors.primaryBlueDark,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('添加账户', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddStep1() {
    const order = [
      AccountCategory.bank, AccountCategory.stock, AccountCategory.fund,
      AccountCategory.property, AccountCategory.insurance, AccountCategory.debt, AccountCategory.custom,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StepHeader(title: '选择账户类型', step: '1/3', onBack: _resetAdd),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: order.map((cat) {
            final cfg = kCategoryConfig[cat]!;
            return _CategoryButton(
              cfg: cfg,
              onTap: () => setState(() {
                _selectedCategory = cat;
                _view = _View.addStep2;
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddStep2() {
    final cfg = kCategoryConfig[_selectedCategory!]!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StepHeader(title: '账户信息', step: '2/3', onBack: () => setState(() => _view = _View.addStep1)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(cfg.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(cfg.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900)),
              ]),
              const SizedBox(height: 16),
              _TextField(controller: _institutionCtrl, label: '机构名称', hint: '如：招商银行'),
              const SizedBox(height: 12),
              _TextField(controller: _aliasCtrl, label: '账户别名（可选）', hint: '如：工资卡'),
              if (_selectedCategory == AccountCategory.bank) ...[
                const SizedBox(height: 16),
                const Text('账户类型', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
                const SizedBox(height: 8),
                Row(children: [
                  _ChoiceChip(
                    label: '储蓄卡',
                    selected: _subType == AccountSubType.savings,
                    onTap: () => setState(() => _subType = AccountSubType.savings),
                  ),
                  const SizedBox(width: 8),
                  _ChoiceChip(
                    label: '信用卡',
                    selected: _subType == AccountSubType.credit,
                    onTap: () => setState(() => _subType = AccountSubType.credit),
                  ),
                ]),
              ],
              if (_selectedCategory == AccountCategory.stock) ...[
                const SizedBox(height: 16),
                const Text('交易市场', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
                const SizedBox(height: 8),
                Row(children: MarketType.values.map((m) {
                  final label = switch (m) {
                    MarketType.a  => 'A股',
                    MarketType.hk => '港股',
                    MarketType.us => '美股',
                  };
                  final selected = _markets.contains(m);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ChoiceChip(
                      label: label,
                      selected: selected,
                      onTap: () => setState(() {
                        selected ? _markets.remove(m) : _markets.add(m);
                      }),
                    ),
                  );
                }).toList()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: '下一步',
          onTap: () => setState(() => _view = _View.addStep3),
        ),
      ],
    );
  }

  Widget _buildAddStep3() {
    final needsCost = _selectedCategory == AccountCategory.stock ||
                      _selectedCategory == AccountCategory.fund;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StepHeader(title: '资产金额', step: '3/3', onBack: () => setState(() => _view = _View.addStep2)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextField(controller: _amountCtrl, label: '当前金额（元）', hint: '0',
                  keyboardType: TextInputType.number),
              if (needsCost) ...[
                const SizedBox(height: 12),
                _TextField(controller: _investedCtrl, label: '累计投入（元，可选）', hint: '0',
                    keyboardType: TextInputType.number),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(label: '保存账户', onTap: _submitAdd),
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final CategoryConfig cfg;
  final List<Account> accounts;
  final ValueChanged<Account> onAccountTap;

  const _CategoryGroup({required this.cfg, required this.accounts, required this.onAccountTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(children: [
                Text(cfg.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(cfg.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
              ]),
            ),
            const Divider(height: 1, color: AppColors.gray50),
            ...accounts.map((acc) => InkWell(
              onTap: () => onAccountTap(acc),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(acc.institutionName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray900)),
                      if (acc.alias != null)
                        Text(acc.alias!,
                            style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                    ],
                  )),
                  Text(
                    '${acc.isLiability ? '-' : ''}${formatAmount(acc.currentAmount, compact: true)}',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: acc.isLiability ? AppColors.error : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _UpdateSheet extends StatelessWidget {
  final Account account;
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;
  final VoidCallback onSave;

  const _UpdateSheet({
    required this.account,
    required this.amountCtrl,
    required this.noteCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = kCategoryConfig[account.category]!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        16, 20, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(cfg.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '更新 ${account.institutionName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray900),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.gray400),
              onPressed: () => Navigator.pop(context),
            ),
          ]),
          const SizedBox(height: 16),
          _TextField(controller: amountCtrl, label: '最新金额（元）', hint: '0',
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _TextField(controller: noteCtrl, label: '备注（可选）', hint: '如：月末结算'),
          const SizedBox(height: 20),
          _PrimaryButton(label: '保存', onTap: onSave),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String step;
  final VoidCallback onBack;

  const _StepHeader({required this.title, required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onTap: onBack,
        child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.gray700),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray900)),
      ),
      Text(step, style: const TextStyle(fontSize: 13, color: AppColors.gray400)),
    ]);
  }
}

class _CategoryButton extends StatelessWidget {
  final CategoryConfig cfg;
  final VoidCallback onTap;

  const _CategoryButton({required this.cfg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(children: [
          Text(cfg.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(cfg.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
        ]),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.gray200,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: selected ? AppColors.primaryBlueDark : AppColors.gray500,
            )),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
            )),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
);
