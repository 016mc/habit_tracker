import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 颜色选择器组件
/// 以圆形色块网格展示可选颜色，支持单选
class ColorSelector extends StatelessWidget {
  /// 当前选中的颜色值（ARGB int）
  final int selectedColorValue;

  /// 颜色选择回调，返回颜色值
  final ValueChanged<int> onColorChanged;

  const ColorSelector({
    super.key,
    required this.selectedColorValue,
    required this.onColorChanged,
  });

  /// 预设可选颜色列表
  static const List<int> _presetColors = [
    // 经典色系
    0xFFEF4444, // 红色
    0xFFF97316, // 橙色
    0xFFF59E0B, // 琥珀色
    0xFFEAB308, // 黄色
    0xFF84CC16, // 黄绿色
    0xFF22C55E, // 绿色
    0xFF14B8A6, // 青色
    0xFF06B6D4, // 蓝绿色
    0xFF3B82F6, // 蓝色
    0xFF6366F1, // 靛蓝色
    0xFF8B5CF6, // 紫色
    0xFFA855F7, // 亮紫色
    0xFFEC4899, // 粉色
    0xFFF43F5E, // 玫红色
    0xFF64748B, // 灰色
    0xFF1E293B, // 深灰色
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '选择颜色',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 颜色网格
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _presetColors.map((colorValue) {
            final isSelected = colorValue == selectedColorValue;
            final color = Color(colorValue);

            return _ColorItem(
              color: color,
              isSelected: isSelected,
              onTap: () => onColorChanged(colorValue),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 单个颜色选项组件
class _ColorItem extends StatelessWidget {
  /// 颜色值
  final Color color;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onTap;

  const _ColorItem({
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 3 : 1,
        ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
