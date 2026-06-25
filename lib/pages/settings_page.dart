import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../data/app_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _reminderOn = true;
  String _cycle    = 'monthly';
  bool _darkMode   = false;

  static const _cycleLabels = {
    'weekly': '每周', 'biweekly': '每两周', 'monthly': '每月',
  };

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            const Text('设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            const SizedBox(height: 2),
            const Text('偏好与数据管理',
                style: TextStyle(fontSize: 12, color: AppColors.gray400)),
            const SizedBox(height: 24),

            _SectionLabel(label: '提醒'),
            _SettingsCard(children: [
              _ToggleRow(
                icon: Icons.notifications_outlined,
                iconBg: AppColors.primaryBlue,
                label: '更新提醒',
                sub: '定期提醒您记录最新资产',
                value: _reminderOn,
                onChanged: (v) => setState(() => _reminderOn = v),
              ),
              if (_reminderOn) ...[
                const Divider(height: 1, color: AppColors.gray50),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('提醒周期',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray500)),
                      const SizedBox(height: 8),
                      Row(
                        children: _cycleLabels.entries.map((e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              onTap: () => setState(() => _cycle = e.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _cycle == e.key
                                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                                      : AppColors.gray50,
                                  border: Border.all(
                                    color: _cycle == e.key ? AppColors.primaryBlue : AppColors.gray200,
                                    width: _cycle == e.key ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(e.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w500,
                                      color: _cycle == e.key ? AppColors.primaryBlueDark : AppColors.gray500,
                                    )),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 20),

            _SectionLabel(label: '显示'),
            _SettingsCard(children: [
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                iconBg: const Color(0xFF6366F1),
                label: '深色模式',
                sub: '暗色背景，保护眼睛',
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _snack('深色模式将在后续版本支持');
                },
              ),
              const Divider(height: 1, color: AppColors.gray50),
              _NavRow(
                icon: Icons.language,
                iconBg: const Color(0xFF06B6D4),
                label: '本位货币',
                sub: '人民币（CNY）',
                onTap: () => _snack('多货币将在后续版本支持'),
              ),
            ]),
            const SizedBox(height: 20),

            _SectionLabel(label: '数据管理'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.download_outlined,
                iconBg: AppColors.success,
                label: '导出数据',
                sub: '导出为 CSV / Excel 文件',
                onTap: () => _snack('已生成导出文件（演示）'),
              ),
              const Divider(height: 1, color: AppColors.gray50),
              _NavRow(
                icon: Icons.cloud_upload_outlined,
                iconBg: AppColors.purple,
                label: '备份与恢复',
                sub: '本地文件备份 · 加密云备份',
                onTap: () => _snack('云备份将在后续版本支持'),
              ),
            ]),
            const SizedBox(height: 20),

            _SectionLabel(label: '隐私与安全'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.shield_outlined,
                iconBg: AppColors.warning,
                label: '隐私政策',
                sub: '了解数据如何被使用',
                onTap: () => _snack('本地优先，数据不离设备'),
              ),
            ]),
            const SizedBox(height: 20),

            _SectionLabel(label: '危险操作'),
            _SettingsCard(children: [
              _NavRow(
                icon: Icons.delete_outline,
                iconBg: AppColors.error,
                label: '清除所有数据',
                sub: '删除全部账户与历史记录',
                labelColor: AppColors.error,
                onTap: () => _confirmReset(context),
              ),
            ]),
            const SizedBox(height: 32),
            const Text('余数 · v1.0.0 (prototype)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.gray200)),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作将删除全部账户与历史快照，无法撤销。确认继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppStore>().reset();
              Navigator.pop(ctx);
              _snack('数据已清除');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppColors.gray400, letterSpacing: 0.8,
          )),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon, required this.iconBg,
    required this.label, this.sub,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(children: [
        _IconBox(icon: icon, bg: iconBg),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray900)),
            if (sub != null)
              Text(sub!, style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
          ],
        )),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44, height: 24,
            decoration: BoxDecoration(
              color: value ? AppColors.primaryBlueDark : AppColors.gray200,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(2),
                width: 20, height: 20,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final Color? labelColor;

  const _NavRow({
    required this.icon, required this.iconBg,
    required this.label, this.sub,
    required this.onTap, this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(children: [
          _IconBox(icon: icon, bg: iconBg),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: labelColor ?? AppColors.gray900,
                  )),
              if (sub != null)
                Text(sub!, style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
            ],
          )),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.gray300),
        ]),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg;
  const _IconBox({required this.icon, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
