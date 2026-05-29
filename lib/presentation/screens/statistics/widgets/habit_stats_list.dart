import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/habit_model.dart';
import '../../../../data/models/habit_stats_model.dart';
import '../../../widgets/common/app_card.dart';

/// 习惯统计列表项
///
/// 展示单个习惯的统计信息：名称、完成率进度条、连续天数。
class HabitStatsList extends StatelessWidget {
  /// 习惯列表
  final List<Habit> habits;

  /// 对应的统计数据列表（通过habitId关联）
  final List<HabitStats> statsList;

  const HabitStatsList({
    super.key,
    required this.habits,
    required this.statsList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (habits.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                '暂无习惯数据',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '习惯完成率',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 习惯列表
          ...habits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;
            final stats = statsList.where(
              (s) => s.habitId == habit.id,
            ).firstOrNull;

            if (index > 0) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildHabitStatItem(context, habit, stats),
                ],
              );
            }
            return _buildHabitStatItem(context, habit, stats);
          }),
        ],
      ),
    );
  }

  /// 构建单个习惯统计项
  Widget _buildHabitStatItem(
    BuildContext context,
    Habit habit,
    HabitStats? stats,
  ) {
    final theme = Theme.of(context);
    final completionRate = stats?.completionRate ?? 0.0;
    final currentStreak = stats?.currentStreak ?? 0;
    final categoryColor = AppColors.getCategoryColor(habit.category.value);

    return Row(
      children: [
        // 分类颜色指示器
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        // 名称和连续天数
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 习惯名称
              Text(
                habit.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // 完成率进度条
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(completionRate * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 连续天数
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: currentStreak > 0
                ? AppColors.warning.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 14,
                color: currentStreak > 0
                    ? AppColors.warning
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Text(
                '${currentStreak}天',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: currentStreak > 0
                      ? AppColors.warning
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
