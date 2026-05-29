import 'package:flutter/material.dart';

/// 图标选择器组件
/// 以网格形式展示可选图标，支持单选
class IconSelector extends StatelessWidget {
  /// 当前选中的图标名称
  final String selectedIcon;

  /// 图标选择回调，返回图标名称
  final ValueChanged<String> onIconChanged;

  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconChanged,
  });

  /// 可选图标列表（名称 -> 图标数据映射）
  static const Map<String, IconData> _availableIcons = {
    // 日常类
    'circle': Icons.circle_rounded,
    'star': Icons.star_rounded,
    'favorite': Icons.favorite_rounded,
    'thumb_up': Icons.thumb_up_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'local_fire_department': Icons.local_fire_department_rounded,
    // 学习类
    'menu_book': Icons.menu_book_rounded,
    'school': Icons.school_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'create': Icons.create_rounded,
    'translate': Icons.translate_rounded,
    'code': Icons.code_rounded,
    // 健康类
    'fitness_center': Icons.fitness_center_rounded,
    'directions_run': Icons.directions_run_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'water_drop': Icons.water_drop_rounded,
    'medication': Icons.medication_rounded,
    'monitor_heart': Icons.monitor_heart_rounded,
    // 生活类
    'coffee': Icons.coffee_rounded,
    'bedtime': Icons.bedtime_rounded,
    'restaurant': Icons.restaurant_rounded,
    'cleaning_services': Icons.cleaning_services_rounded,
    'music_note': Icons.music_note_rounded,
    'palette': Icons.palette_rounded,
    // 其他
    'sports_esports': Icons.sports_esports_rounded,
    'camera_alt': Icons.camera_alt_rounded,
    'pets': Icons.pets_rounded,
    'nature': Icons.nature_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '选择图标',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 图标网格 - 使用 LayoutBuilder 获取可用宽度
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 400 ? 6 : 4;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
              children: _availableIcons.entries.map((entry) {
            final isSelected = entry.key == selectedIcon;
            return _IconItem(
              iconData: entry.value,
              iconName: entry.key,
              isSelected: isSelected,
              onTap: () => onIconChanged(entry.key),
            );
          }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// 单个图标选项组件
class _IconItem extends StatelessWidget {
  /// 图标数据
  final IconData iconData;

  /// 图标名称
  final String iconName;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  const _IconItem({
    required this.iconData,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          iconData,
          size: 24,
          color: isSelected ? primaryColor : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
