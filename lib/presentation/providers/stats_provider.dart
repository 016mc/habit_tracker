import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_stats_model.dart';
import '../../domain/services/checkin_service.dart';
import 'checkin_provider.dart';

/// 统计状态
///
/// 包含习惯统计数据、热力图数据等
class StatsState {
  /// 各习惯的统计数据映射（habitId -> HabitStats）
  final Map<String, HabitStats> statsMap;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息（null表示无错误）
  final String? error;

  const StatsState({
    this.statsMap = const {},
    this.isLoading = false,
    this.error,
  });

  /// 创建副本
  StatsState copyWith({
    Map<String, HabitStats>? statsMap,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatsState(
      statsMap: statsMap ?? this.statsMap,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// 获取指定习惯的统计数据
  HabitStats? getStats(String habitId) {
    return statsMap[habitId];
  }
}

/// 统计状态管理 Notifier
///
/// 使用 StateNotifier 管理统计数据，提供统计计算、连续打卡天数计算、热力图数据等功能。
class StatsNotifier extends StateNotifier<StatsState> {
  /// 打卡业务服务
  final CheckInService _checkInService;

  StatsNotifier({
    required CheckInService checkInService,
  })  : _checkInService = checkInService,
        super(const StatsState());

  // ============================================================
  // 统计数据加载
  // ============================================================

  /// 加载所有习惯的统计数据
  ///
  /// [habits] 需要统计的习惯列表
  Future<void> loadAllStats(List<Habit> habits) async {
    if (habits.isEmpty) {
      state = state.copyWith(statsMap: {}, clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final statsMap = <String, HabitStats>{};

      for (final habit in habits) {
        try {
          final stats = await _checkInService.getHabitStats(habit);
          statsMap[habit.id] = stats;
        } catch (_) {
          // 单个习惯统计失败不影响其他习惯
          statsMap[habit.id] = HabitStats(
            habitId: habit.id,
            userId: habit.userId,
          );
        }
      }

      state = state.copyWith(statsMap: statsMap, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载统计数据失败: ${e.toString()}',
      );
    }
  }

  /// 加载单个习惯的统计数据
  ///
  /// [habit] 习惯对象
  Future<void> loadHabitStats(Habit habit) async {
    try {
      final stats = await _checkInService.getHabitStats(habit);
      final updatedStatsMap = Map<String, HabitStats>.from(state.statsMap)
        ..[habit.id] = stats;

      state = state.copyWith(statsMap: updatedStatsMap, clearError: true);
    } catch (e) {
      state = state.copyWith(error: '加载习惯统计失败: ${e.toString()}');
    }
  }

  /// 刷新统计数据（静默刷新）
  ///
  /// [habits] 需要刷新的习惯列表
  Future<void> refreshStats(List<Habit> habits) async {
    try {
      final statsMap = <String, HabitStats>{};

      for (final habit in habits) {
        try {
          final stats = await _checkInService.getHabitStats(habit);
          statsMap[habit.id] = stats;
        } catch (_) {
          // 保留现有统计数据
          if (state.statsMap.containsKey(habit.id)) {
            statsMap[habit.id] = state.statsMap[habit.id]!;
          }
        }
      }

      state = state.copyWith(statsMap: statsMap, clearError: true);
    } catch (e) {
      // 静默刷新失败不改变加载状态
      state = state.copyWith(error: '刷新统计数据失败: ${e.toString()}');
    }
  }

  // ============================================================
  // 连续打卡天数
  // ============================================================

  /// 获取某个习惯的当前连续打卡天数
  ///
  /// [habitId] 习惯ID
  /// 返回连续打卡天数
  Future<int> getCurrentStreak(String habitId) async {
    try {
      return await _checkInService.calculateCurrentStreak(habitId);
    } catch (_) {
      // 如果数据库查询失败，尝试从缓存中获取
      return state.statsMap[habitId]?.currentStreak ?? 0;
    }
  }

  /// 获取某个习惯的最长连续打卡天数
  ///
  /// [habitId] 习惯ID
  /// 返回最长连续打卡天数
  Future<int> getLongestStreak(String habitId) async {
    try {
      return await _checkInService.calculateLongestStreak(habitId);
    } catch (_) {
      // 如果数据库查询失败，尝试从缓存中获取
      return state.statsMap[habitId]?.longestStreak ?? 0;
    }
  }

  // ============================================================
  // 热力图数据
  // ============================================================

  /// 获取某个习惯的热力图数据
  ///
  /// [habitId] 习惯ID
  /// [days] 显示天数（默认90天）
  /// 返回日期到打卡次数的映射
  Future<Map<String, int>> getHeatmapData({
    required String habitId,
    int days = AppConstants.heatmapDays,
  }) async {
    try {
      return await _checkInService.getHeatmapData(
        habitId: habitId,
        days: days,
      );
    } catch (_) {
      // 如果数据库查询失败，尝试从缓存中获取
      return state.statsMap[habitId]?.heatmapData ?? {};
    }
  }

  // ============================================================
  // 最近打卡情况
  // ============================================================

  /// 获取某个习惯最近N天的打卡状态
  ///
  /// [habitId] 习惯ID
  /// [days] 天数（默认7天）
  /// 返回布尔列表，true=已打卡，false=未打卡
  Future<List<bool>> getRecentDaysStatus({
    required String habitId,
    int days = AppConstants.statsRecentDays,
  }) async {
    try {
      return await _checkInService.getRecentDaysCheckInStatus(
        habitId: habitId,
        days: days,
      );
    } catch (_) {
      // 如果数据库查询失败，尝试从缓存中获取
      return state.statsMap[habitId]?.last7Days ?? List.filled(days, false);
    }
  }

  // ============================================================
  // 汇总统计
  // ============================================================

  /// 计算所有习惯的汇总统计
  ///
  /// 返回汇总信息 Map，包含：
  /// - totalHabits: 总习惯数
  /// - checkedToday: 今日已打卡数
  /// - avgCompletionRate: 平均完成率
  /// - maxStreak: 最大连续天数
  Map<String, dynamic> getSummaryStats() {
    final statsList = state.statsMap.values.toList();

    if (statsList.isEmpty) {
      return {
        'totalHabits': 0,
        'checkedToday': 0,
        'avgCompletionRate': 0.0,
        'maxStreak': 0,
      };
    }

    // 计算平均完成率
    final totalRate =
        statsList.fold<double>(0.0, (sum, s) => sum + s.completionRate);
    final avgRate = totalRate / statsList.length;

    // 获取最大连续天数
    final maxStreak = statsList.fold<int>(
      0,
      (max, s) => s.longestStreak > max ? s.longestStreak : max,
    );

    return {
      'totalHabits': statsList.length,
      'checkedToday': 0, // 需要从 CheckInProvider 获取
      'avgCompletionRate': avgRate,
      'maxStreak': maxStreak,
    };
  }

  // ============================================================
  // 错误处理
  // ============================================================

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================================
// Providers
// ============================================================

/// 统计状态管理 Provider
///
/// 监听统计数据的变化，提供统计计算、热力图数据等功能
final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  final checkInService = ref.watch(checkInServiceProvider);
  return StatsNotifier(checkInService: checkInService);
});

/// 某个习惯的统计数据 Provider
///
/// [habitId] 习惯ID
/// 返回该习惯的统计数据（FutureProvider，异步获取）
final habitStatsProvider =
    FutureProvider.family<HabitStats?, String>((ref, habitId) async {
  final statsState = ref.watch(statsProvider);
  final cachedStats = statsState.getStats(habitId);

  // 如果缓存中有数据，直接返回
  if (cachedStats != null) {
    return cachedStats;
  }

  // 缓存中没有数据，返回空
  return null;
});

/// 某个习惯的连续打卡天数 Provider
///
/// [habitId] 习惯ID
/// 返回当前连续打卡天数
final currentStreakProvider =
    FutureProvider.family<int, String>((ref, habitId) async {
  final statsNotifier = ref.read(statsProvider.notifier);
  return await statsNotifier.getCurrentStreak(habitId);
});

/// 某个习惯的最长连续打卡天数 Provider
///
/// [habitId] 习惯ID
/// 返回历史最长连续打卡天数
final longestStreakProvider =
    FutureProvider.family<int, String>((ref, habitId) async {
  final statsNotifier = ref.read(statsProvider.notifier);
  return await statsNotifier.getLongestStreak(habitId);
});

/// 某个习惯的热力图数据 Provider
///
/// [habitId] 习惯ID
/// [days] 显示天数（默认90天）
/// 返回日期到打卡次数的映射
final heatmapDataProvider = FutureProvider.family<Map<String, int>,
    ({String habitId, int days})>((ref, params) async {
  final statsNotifier = ref.read(statsProvider.notifier);
  return await statsNotifier.getHeatmapData(
    habitId: params.habitId,
    days: params.days,
  );
});

/// 某个习惯最近N天打卡状态 Provider
///
/// [habitId] 习惯ID
/// [days] 天数（默认7天）
/// 返回布尔列表
final recentDaysStatusProvider = FutureProvider.family<List<bool>,
    ({String habitId, int days})>((ref, params) async {
  final statsNotifier = ref.read(statsProvider.notifier);
  return await statsNotifier.getRecentDaysStatus(
    habitId: params.habitId,
    days: params.days,
  );
});

/// 汇总统计 Provider
///
/// 提供所有习惯的汇总统计信息
final summaryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final statsNotifier = ref.watch(statsProvider.notifier);
  return statsNotifier.getSummaryStats();
});

/// 所有习惯的统计数据 Provider
///
/// 便捷 Provider，直接提供所有习惯的统计数据 Map
final allStatsMapProvider = Provider<Map<String, HabitStats>>((ref) {
  final statsState = ref.watch(statsProvider);
  return statsState.statsMap;
});
