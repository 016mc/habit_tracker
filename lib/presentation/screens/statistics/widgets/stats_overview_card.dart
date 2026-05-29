import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/common/app_card.dart';

/// 统计概览卡片
///
/// 以 2x2 网格展示4个关键指标：总打卡次数、当前连续天数、最长连续天数、总完成率。
/// 每个指标带图标和数值，简约设计风格。
class StatsOverviewCard extends StatelessWidget {
  /// 总打卡次数
  final int totalCheckIns;

  /// 当前连续打卡天数
  final int currentStreak;

  /// 最长连续打卡天数
  final int longestStreak;

  /// 总完成率（0.0 ~ 1.0）
  final double completionRate;

  const StatsOverviewCard({
    super.key,
    required this.totalCheckIns,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            '数据总览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 网格
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                iconBgColor: AppColors.success.withOpacity(0.1),
                label: '总打卡',
                value: totalCheckIns.toString(),
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department_outlined,
                iconColor: AppColors.warning,
                iconBgColor: AppColors.warning.withOpacity(0.1),
                label: '当前连续',
                value: '${currentStreak}天',
              ),
              _buildStatItem(
                context,
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.supplement,
                iconBgColor: AppColors.supplement.withOpacity(0.1),
                label: '最长连续',
                value: '${longestStreak}天',
              ),
              _buildStatItem(
                context,
                icon: Icons.pie_chart_outline,
                iconColor: AppColors.learning,
                iconBgColor: AppColors.learning.withOpacity(0.1),
                label: '总完成率',
                value: '${(completionRate * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建单个统计指标项
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),

          // 数值
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),

          // 标签
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
