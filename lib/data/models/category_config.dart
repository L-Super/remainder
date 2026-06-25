import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'account_category.dart';

class CategoryConfig {
  final String name;
  final String icon;
  final Color color;
  final bool isLiabilityDefault;

  const CategoryConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.isLiabilityDefault,
  });
}

const Map<AccountCategory, CategoryConfig> kCategoryConfig = {
  AccountCategory.bank:      CategoryConfig(name: '银行存款', icon: '🏦', color: AppColors.bank,     isLiabilityDefault: false),
  AccountCategory.stock:     CategoryConfig(name: '股票账户', icon: '📈', color: AppColors.stock,    isLiabilityDefault: false),
  AccountCategory.fund:      CategoryConfig(name: '基金账户', icon: '💰', color: AppColors.fund,     isLiabilityDefault: false),
  AccountCategory.property:  CategoryConfig(name: '固定资产', icon: '🏠', color: AppColors.property, isLiabilityDefault: false),
  AccountCategory.insurance: CategoryConfig(name: '保险理财', icon: '🔒', color: AppColors.insurance,isLiabilityDefault: false),
  AccountCategory.debt:      CategoryConfig(name: '负债',     icon: '💳', color: AppColors.debt,     isLiabilityDefault: true),
  AccountCategory.custom:    CategoryConfig(name: '自定义',   icon: '➕', color: AppColors.custom,   isLiabilityDefault: false),
};

const List<AccountCategory> kCategoryOrder = [
  AccountCategory.bank,
  AccountCategory.stock,
  AccountCategory.fund,
  AccountCategory.property,
  AccountCategory.insurance,
  AccountCategory.debt,
  AccountCategory.custom,
];
