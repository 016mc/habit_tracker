import 'package:flutter/material.dart';

/// 应用配色常量
/// 统一管理应用中使用的所有颜色值
class AppColors {
  AppColors._();

  // ============================================================
  // 主题色
  // ============================================================

  /// 主色调 - 清新薄荷绿
  static const Color primary = Color(0xFF4ADE80);

  /// 主色调深色变体
  static const Color primaryDark = Color(0xFF22C55E);

  /// 主色调浅色变体
  static const Color primaryLight = Color(0xFFBBF7D0);

  // ============================================================
  // 背景色
  // ============================================================

  /// 浅色模式背景色
  static const Color background = Color(0xFFF8FAFC);

  /// 浅色模式表面色（卡片等）
  static const Color surface = Color(0xFFFFFFFF);

  /// 深色模式背景色
  static const Color darkBackground = Color(0xFF0F172A);

  /// 深色模式表面色
  static const Color darkSurface = Color(0xFF1E293B);

  // ============================================================
  // 文字颜色
  // ============================================================

  /// 主要文字颜色
  static const Color textPrimary = Color(0xFF1E293B);

  /// 次要文字颜色
  static const Color textSecondary = Color(0xFF64748B);

  /// 提示文字颜色
  static const Color textHint = Color(0xFF94A3B8);

  /// 深色模式主要文字色
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  /// 深色模式次要文字色
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ============================================================
  // 习惯分类颜色
  // ============================================================

  /// 补充剂类 - 琥珀色
  static const Color supplement = Color(0xFFF59E0B);

  /// 学习类 - 蓝色
  static const Color learning = Color(0xFF3B82F6);

  /// 游戏类 - 紫色
  static const Color gaming = Color(0xFF8B5CF6);

  /// 运动类 - 红色
  static const Color exercise = Color(0xFFEF4444);

  /// 自定义类 - 灰色
  static const Color custom = Color(0xFF6B7280);

  // ============================================================
  // 热力图颜色 - 5级绿色渐变（从浅到深）
  // ============================================================

  /// 热力图 - 第1级（最浅，无打卡）
  static const Color heatmapLevel0 = Color(0xFFE8F5E9);

  /// 热力图 - 第2级（少量打卡）
  static const Color heatmapLevel1 = Color(0xFFA5D6A7);

  /// 热力图 - 第3级
  static const Color heatmapLevel2 = Color(0xFF66BB6A);

  /// 热力图 - 第4级
  static const Color heatmapLevel3 = Color(0xFF2E7D32);

  /// 热力图 - 第5级（最深，全部完成）
  static const Color heatmapLevel4 = Color(0xFF1B5E20);

  /// 热力图颜色列表，按等级从低到高排列
  static const List<Color> heatmapColors = [
    heatmapLevel0,
    heatmapLevel1,
    heatmapLevel2,
    heatmapLevel3,
    heatmapLevel4,
  ];

  // ============================================================
  // 状态色
  // ============================================================

  /// 成功色 - 绿色
  static const Color success = Color(0xFF22C55E);

  /// 警告色 - 橙色
  static const Color warning = Color(0xFFF97316);

  /// 错误色 - 红色
  static const Color error = Color(0xFFEF4444);

  /// 信息色 - 蓝色
  static const Color info = Color(0xFF3B82F6);

  // ============================================================
  // 分割线与边框
  // ============================================================

  /// 浅色模式分割线
  static const Color divider = Color(0xFFE2E8F0);

  /// 深色模式分割线
  static const Color darkDivider = Color(0xFF334155);

  // ============================================================
  // 阴影色
  // ============================================================

  /// 浅色模式阴影
  static const Color shadow = Color(0x1A000000);

  /// 深色模式阴影
  static const Color darkShadow = Color(0x33000000);

  // ============================================================
  // 根据分类获取对应颜色的辅助方法
  // ============================================================

  /// 根据习惯分类获取对应颜色
  static Color getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'supplement':
        return supplement;
      case 'learning':
        return learning;
      case 'gaming':
        return gaming;
      case 'exercise':
        return exercise;
      case 'custom':
        return custom;
      default:
        return primary;
    }
  }

  /// 根据颜色值（int）获取Color对象
  static Color fromValue(int value) => Color(value);

  /// 根据打卡完成率获取对应热力图颜色
  /// [rate] 完成率，取值范围 0.0 ~ 1.0
  static Color getHeatmapColor(double rate) {
    if (rate <= 0.0) return heatmapLevel0;
    if (rate <= 0.25) return heatmapLevel1;
    if (rate <= 0.5) return heatmapLevel2;
    if (rate <= 0.75) return heatmapLevel3;
    return heatmapLevel4;
  }
}
