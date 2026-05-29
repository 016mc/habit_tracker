import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/checkin_model.dart';
import '../../data/models/habit_model.dart';
import '../../domain/services/checkin_service.dart';
import 'habit_provider.dart';

/// 打卡状态
///
/// 包含今日打卡记录、各习惯的打卡状态等信息
class CheckInState {
  /// 今日打卡记录列表
  final List<CheckIn> todayCheckIns;

  /// 各习惯今日是否已打卡的映射（habitId -> 是否已打卡）
  final Map<String, bool> checkInStatusMap;

  /// 是否正在执行操作
  final bool isLoading;

  /// 错误信息（null表示无错误）
  final String? error;

  const CheckInState({
    this.todayCheckIns = const [],
    this.checkInStatusMap = const {},
    this.isLoading = false,
    this.error,
  });

  /// 创建副本
  CheckInState copyWith({
    List<CheckIn>? todayCheckIns,
    Map<String, bool>? checkInStatusMap,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CheckInState(
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      checkInStatusMap: checkInStatusMap ?? this.checkInStatusMap,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// 判断某个习惯今日是否已打卡
  bool isCheckedIn(String habitId) {
    return checkInStatusMap[habitId] ?? false;
  }

  /// 获取今日已打卡的习惯数量
  int get checkedInCount {
    return checkInStatusMap.values.where((checked) => checked).length;
  }
}

/// 打卡状态管理 Notifier
///
/// 使用 StateNotifier 管理打卡状态，提供打卡、撤销、补签等功能。
class CheckInNotifier extends StateNotifier<CheckInState> {
  /// 打卡业务服务
  final CheckInService _checkInService;

  /// 当前用户ID
  final String _userId;

  CheckInNotifier({
    required CheckInService checkInService,
    required String userId,
  })  : _checkInService = checkInService,
        _userId = userId,
        super(const CheckInState());

  // ============================================================
  // 加载数据
  // ============================================================

  /// 加载今日打卡状态
  ///
  /// 获取所有活跃习惯的今日打卡情况
  /// [activeHabits] 当前活跃习惯列表
  Future<void> loadTodayCheckIns(List<Habit> activeHabits) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final todayCheckIns = <CheckIn>[];
      final statusMap = <String, bool>{};

      for (final habit in activeHabits) {
        final isChecked = await _checkInService.isCheckedInToday(habit.id);
        statusMap[habit.id] = isChecked;

        if (isChecked) {
          final checkIns =
              await _checkInService.getTodayCheckInsByHabit(habit.id);
          todayCheckIns.addAll(checkIns);
        }
      }

      state = state.copyWith(
        todayCheckIns: todayCheckIns,
        checkInStatusMap: statusMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载打卡状态失败: ${e.toString()}',
      );
    }
  }

  /// 刷新今日打卡状态（静默刷新）
  ///
  /// [activeHabits] 当前活跃习惯列表
  Future<void> refreshTodayCheckIns(List<Habit> activeHabits) async {
    try {
      final todayCheckIns = <CheckIn>[];
      final statusMap = <String, bool>{};

      for (final habit in activeHabits) {
        final isChecked = await _checkInService.isCheckedInToday(habit.id);
        statusMap[habit.id] = isChecked;

        if (isChecked) {
          final checkIns =
              await _checkInService.getTodayCheckInsByHabit(habit.id);
          todayCheckIns.addAll(checkIns);
        }
      }

      state = state.copyWith(
        todayCheckIns: todayCheckIns,
        checkInStatusMap: statusMap,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: '刷新打卡状态失败: ${e.toString()}');
    }
  }

  // ============================================================
  // 打卡操作
  // ============================================================

  /// 执行打卡操作
  ///
  /// [habitId] 习惯ID
  /// [count] 打卡数量（默认1）
  /// [note] 备注
  Future<void> checkIn({
    required String habitId,
    int count = 1,
    String note = '',
  }) async {
    try {
      final checkIn = await _checkInService.checkIn(
        habitId: habitId,
        userId: _userId,
        count: count,
        note: note,
      );

      // 更新状态
      final updatedCheckIns = [...state.todayCheckIns, checkIn];
      final updatedStatusMap = Map<String, bool>.from(state.checkInStatusMap)
        ..[habitId] = true;

      state = state.copyWith(
        todayCheckIns: updatedCheckIns,
        checkInStatusMap: updatedStatusMap,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: '打卡失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 撤销打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 要撤销的日期（默认今天）
  Future<void> undoCheckIn({
    required String habitId,
    String? date,
  }) async {
    try {
      final success = await _checkInService.undoCheckIn(
        habitId: habitId,
        date: date,
      );

      if (success) {
        final targetDate = date ?? AppDateUtils.getTodayString();
        final isToday = targetDate == AppDateUtils.getTodayString();

        if (isToday) {
          // 撤销的是今天的打卡，更新状态
          final updatedCheckIns = state.todayCheckIns
              .where((c) => c.habitId != habitId)
              .toList();
          final updatedStatusMap = Map<String, bool>.from(state.checkInStatusMap)
            ..[habitId] = false;

          state = state.copyWith(
            todayCheckIns: updatedCheckIns,
            checkInStatusMap: updatedStatusMap,
            clearError: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: '撤销打卡失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 补打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 要补打卡的日期（yyyy-MM-dd格式）
  /// [count] 打卡数量（默认1）
  /// [note] 备注
  Future<void> backfillCheckIn({
    required String habitId,
    required String date,
    int count = 1,
    String note = '',
  }) async {
    try {
      await _checkInService.backfillCheckIn(
        habitId: habitId,
        userId: _userId,
        date: date,
        count: count,
        note: note,
      );

      // 补打卡不影响今日打卡状态，只清除错误
      state = state.copyWith(clearError: true);
    } catch (e) {
      state = state.copyWith(error: '补打卡失败: ${e.toString()}');
      rethrow;
    }
  }

  // ============================================================
  // 打卡状态查询
  // ============================================================

  /// 判断某个习惯今日是否已打卡
  ///
  /// 优先从缓存中读取，缓存未命中时从数据库查询
  /// [habitId] 习惯ID
  Future<bool> isCheckedInToday(String habitId) async {
    // 先从缓存中检查
    if (state.checkInStatusMap.containsKey(habitId)) {
      return state.checkInStatusMap[habitId]!;
    }

    // 缓存未命中，从数据库查询
    final isChecked = await _checkInService.isCheckedInToday(habitId);

    // 更新缓存
    final updatedStatusMap = Map<String, bool>.from(state.checkInStatusMap)
      ..[habitId] = isChecked;
    state = state.copyWith(checkInStatusMap: updatedStatusMap);

    return isChecked;
  }

  /// 检查是否可以补打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 要补打卡的日期
  Future<bool> canBackfillCheckIn({
    required String habitId,
    required String date,
  }) async {
    return await _checkInService.canBackfillCheckIn(
      habitId: habitId,
      date: date,
    );
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

/// 打卡业务服务 Provider
///
/// 提供全局单例的 CheckInService 实例
final checkInServiceProvider = Provider<CheckInService>((ref) {
  return CheckInService();
});

/// 打卡状态管理 Provider
///
/// 监听打卡状态的变化，提供打卡、撤销、补签等功能
final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  final checkInService = ref.watch(checkInServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return CheckInNotifier(checkInService: checkInService, userId: userId);
});

/// 今日已打卡数量 Provider
///
/// 便捷 Provider，直接提供今日已打卡的习惯数量
final todayCheckedInCountProvider = Provider<int>((ref) {
  final checkInState = ref.watch(checkInProvider);
  return checkInState.checkedInCount;
});

/// 某个习惯今日是否已打卡的 Provider
///
/// [habitId] 习惯ID
/// 返回该习惯今日是否已打卡
final habitCheckedInProvider = FutureProvider.family<bool, String>((ref, habitId) async {
  final checkInNotifier = ref.read(checkInProvider.notifier);
  return await checkInNotifier.isCheckedInToday(habitId);
});
