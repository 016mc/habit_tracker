import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/habit_model.dart';
import '../../../../data/models/habit_stats_model.dart';
import '../../providers/habit_provider.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_card.dart';
import 'widgets/heatmap_widget.dart';
import 'widgets/habit_stats_list.dart';
import 'widgets/stats_overview_card.dart';

/// 统计页面
///
/// 展示用户的习惯打卡统计数据，包括：
/// - 顶部总览卡片（总打卡次数、当前连续天数、最长连续天数、总完成率）
/// - GitHub风格热力图
/// - 按习惯分类的完成率列表
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟加载统计数据，确保 Provider 已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 加载习惯列表和统计数据
  void _loadData() {
    final habits = ref.read(habitProvider).habits;
    if (habits.isNotEmpty) {
      ref.read(statsProvider.notifier).loadAllStats(habits);
    }
  }

  /// 计算所有习惯的汇总热力图数据（合并各习惯的打卡次数）
  Map<String, int> _getMergedHeatmapData(Map<String, HabitStats> statsMap) {
    final merged = <String, int>{};
    for (final stats in statsMap.values) {
      for (final entry in stats.heatmapData.entries) {
        merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
      }
    }
    return merged;
  }

  /// 计算汇总统计数据
  HabitStats _getSummaryStats(
    List<Habit> habits,
    Map<String, HabitStats> statsMap,
  ) {
    int totalCheckIns = 0;
    int maxCurrentStreak = 0;
    int maxLongestStreak = 0;
    double totalCompletionRate = 0.0;
    int validCount = 0;

    for (final habit in habits) {
      final stats = statsMap[habit.id];
      if (stats != null) {
        totalCheckIns += stats.totalCheckIns;
        if (stats.currentStreak > maxCurrentStreak) {
          maxCurrentStreak = stats.currentStreak;
        }
        if (stats.longestStreak > maxLongestStreak) {
          maxLongestStreak = stats.longestStreak;
        }
        totalCompletionRate += stats.completionRate;
        validCount++;
      }
    }

    // 合并所有习惯的热力图数据
    final mergedHeatmap = _getMergedHeatmapData(statsMap);

    return HabitStats(
      habitId: 'all',
      userId: '',
      currentStreak: maxCurrentStreak,
      longestStreak: maxLongestStreak,
      totalCheckIns: totalCheckIns,
      completionRate: validCount > 0 ? totalCompletionRate / validCount : 0.0,
      heatmapData: mergedHeatmap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitState = ref.watch(habitProvider);
    final statsState = ref.watch(statsProvider);

    final habits = habitState.habits;
    final statsMap = statsState.statsMap;

    // 计算汇总统计
    final summaryStats = _getSummaryStats(habits, statsMap);

    // 构建各习惯的统计数据列表
    final statsList = habits
        .map((h) => statsMap[h.id])
        .whereType<HabitStats>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: statsState.isLoading && statsMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppTheme.pagePadding.add(
                const EdgeInsets.only(bottom: 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 统计概览卡片
                  StatsOverviewCard(
                    totalCheckIns: summaryStats.totalCheckIns,
                    currentStreak: summaryStats.currentStreak,
                    longestStreak: summaryStats.longestStreak,
                    completionRate: summaryStats.completionRate,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // 热力图
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '打卡热力图',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        HeatmapWidget(
                          heatmapData: summaryStats.heatmapData,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // 习惯统计列表
                  if (habits.isNotEmpty && statsList.isNotEmpty)
                    HabitStatsList(
                      habits: habits,
                      statsList: statsList,
                    )
                  else if (!statsState.isLoading)
                    // 无数据提示
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '暂无统计数据',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '开始打卡后这里将展示你的统计信息',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
