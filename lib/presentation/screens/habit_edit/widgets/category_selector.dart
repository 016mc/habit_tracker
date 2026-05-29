import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/habit_model.dart';

/// 分类选择器组件
/// 以网格形式展示所有可选习惯分类，支持单选
class CategorySelector extends StatelessWidget {
  /// 当前选中的分类
  final HabitCategory selectedCategory;

  /// 分类选择回调
  final ValueChanged<HabitCategory> onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  /// 分类对应的图标映射
  static const Map<HabitCategory, IconData> _categoryIcons = {
    HabitCategory.supplement: Icons.medication_rounded,
    HabitCategory.learning: Icons.menu_book_rounded,
    HabitCategory.gaming: Icons.sports_esports_rounded,
    HabitCategory.exercise: Icons.fitness_center_rounded,
    HabitCategory.custom: Icons.edit_rounded,
  };

  /// 分类对应的颜色映射
  static const Map<HabitCategory, Color> _categoryColors = {
    HabitCategory.supplement: AppColors.supplement,
    HabitCategory.learning: AppColors.learning,
    HabitCategory.gaming: AppColors.gaming,
    HabitCategory.exercise: AppColors.exercise,
    HabitCategory.custom: AppColors.custom,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '习惯分类',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 分类网格 - 使用 LayoutBuilder 获取可用宽度
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 400 ? 3 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: HabitCategory.values.map((category) {
            final isSelected = category == selectedCategory;
            final color = _categoryColors[category]!;
            final icon = _categoryIcons[category]!;

            return _CategoryItem(
              icon: icon,
              label: category.label,
              color: color,
              isSelected: isSelected,
              onTap: () => onCategoryChanged(category),
            );
          }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// 单个分类选项组件
class _CategoryItem extends StatelessWidget {
  /// 分类图标
  final IconData icon;

  /// 分类名称
  final String label;

  /// 分类颜色
  final Color color;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
